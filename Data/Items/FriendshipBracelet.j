//TESH.scrollpos=364
//TESH.alwaysfold=0
//! runtextmacro Scope("FriendshipBracelet")
    private struct Data
        Unit caster
        timer delayTimer
        Unit target
    endstruct

    globals
        public constant integer ITEM_ID = 'I01I'
        public constant integer SPELL_ID = 'A040'

        private constant real EFFECT_LIGHTNING_DURATION = 0.3
        private constant string EFFECT_LIGHTNING_PATH = "CLPB"
        private constant real JUMP_DELAY = 0.175
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function Ending_Target takes Data d, Unit target returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById(targetId, FriendshipBracelet_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, FriendshipBracelet_SCOPE_ID) == TABLE_EMPTY) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DECAY" )
        endif
    endfunction

    private function Ending takes Unit caster, Data d, timer delayTimer, boolean isTargetNotNull, Unit target returns nothing
        call d.destroy()
        call RemoveUnitRemainingReference( caster )
        call FlushAttachedInteger( delayTimer, FriendshipBracelet_SCOPE_ID )
        call DestroyTimerWJ( delayTimer )
        if ( isTargetNotNull ) then
            call Ending_Target(d, target)
        endif
    endfunction

    private function TargetConditions_Single takes player casterOwner, Unit checkingUnit returns boolean
        set TEMP_UNIT_SELF = checkingUnit.self
        if ( GetUnitState( TEMP_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) == false ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitMagicImmunity( checkingUnit ) > 0 ) then
            return false
        endif
        if ( GetUnitInvulnerability( checkingUnit ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( checkingUnit ) ) then
            return false
        endif
        return true
    endfunction

    //! runtextmacro Scope("Buff")
        globals
            private constant real Buff_AREA_RANGE = 500.
            private constant real Buff_DURATION = 10.
            private group Buff_ENUM_GROUP
            private constant real Buff_MAX_RANGE = 800.
            private constant real Buff_MAX_RANGE_SQUARE = Buff_MAX_RANGE * Buff_MAX_RANGE
            private constant integer Buff_MAX_TARGETS_AMOUNT = 4
            private trigger Buff_RIP_TRIGGER
            private boolexpr Buff_TARGET_CONDITIONS
            private constant real Buff_UPDATE_TIME = 0.035
        endglobals

        private struct Buff_Data
            timer durationTimer
            Unit array targets[Buff_MAX_TARGETS_AMOUNT]
            integer targetsCount
            timer updateTimer
        endstruct

        globals
            private Buff_Data Buff_RIP_TRIGGER_D
            private Buff_Data Buff_RIP_TRIGGER_TARGET
        endglobals

        //! runtextmacro Scope("Target")
            globals
                private constant string Target_EFFECT_LIGHTNING_PATH = "SPLK"
                //! runtextmacro CreateTableKey("Target_OTHER_TARGET_KEY")
                //! runtextmacro CreateTableKey("Target_TARGET_KEY")
            endglobals

            private struct Target_Data
                lightning effectLightning
                Unit otherTarget
                Unit target
            endstruct

            private function Target_Ending takes Target_Data d, Unit otherTarget, Unit target returns nothing
                local integer targetId = target.id
                local lightning effectLightning = d.effectLightning
                local integer otherTargetId = d.otherTarget.id
                call d.destroy()
                call DestroyLightningEx(effectLightning)
                set effectLightning = null
                call RemoveIntegerFromTableById(otherTargetId, Target_OTHER_TARGET_KEY, d)
                call RemoveIntegerFromTableById(otherTargetId, Target_SCOPE_ID, d)
                call RemoveIntegerFromTableById(targetId, Target_TARGET_KEY, d)
                call RemoveIntegerFromTableById(targetId, Target_SCOPE_ID, d)
            endfunction

            public function Target_EndingByEnding takes Unit target returns nothing
                local Target_Data d
                local integer targetId = target.id
                local integer iteration = CountIntegersInTableById(targetId, Target_SCOPE_ID)
                local Unit otherTarget
                loop
                    set d = GetIntegerFromTableById(targetId, Target_SCOPE_ID, iteration)
                    set otherTarget = d.otherTarget
                    if (otherTarget == target) then
                        call Target_Ending(d, target, d.target)
                    else
                        call Target_Ending(d, d.otherTarget, target)
                    endif
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                endloop
            endfunction

            private function Target_Rip takes integer count, Data d, Target_Data e, Unit otherTarget, Unit target returns nothing
            call BJDebugMsg("rip between "+GetUnitName(target.self)+"; "+GetUnitName(e.otherTarget.self)+" with "+I2S(count))
                if (count == -1) then
                    set Buff_RIP_TRIGGER_D = d
                    set Buff_RIP_TRIGGER_TARGET = target
                    call RunTrigger(Buff_RIP_TRIGGER)
                else
                    call Target_Ending(e, otherTarget, target)
                endif
            endfunction

            public function Target_Update takes Buff_Data d, Unit target returns nothing
                local real differenceX
                local real differenceY
                local Target_Data e
                local integer iteration
                local Unit otherTarget
                local unit otherTargetSelf
                local real otherTargetX
                local real otherTargetY
                local integer targetId = target.id
                local integer count = CountIntegersInTableById(targetId, Target_TARGET_KEY)
                local unit targetSelf
                local real targetX
                local real targetY
                local real targetZ
                if (count > TABLE_EMPTY) then
                    set iteration = count
                    set targetSelf = target.self
                    set targetX = GetUnitX(targetSelf)
                    set targetY = GetUnitY(targetSelf)
                    set targetZ = GetUnitZ(targetSelf, targetX, targetY) + GetUnitOutpactZ(target)
                    set targetSelf = null
                    loop
                        set e = GetIntegerFromTableById(targetId, Target_TARGET_KEY, iteration)
                        set otherTarget = e.otherTarget
                        set otherTargetSelf = otherTarget.self
                        set otherTargetX = GetUnitX(otherTargetSelf)
                        set differenceX = otherTargetX - targetX
                        set otherTargetY = GetUnitY(otherTargetSelf)
                        set differenceY = otherTargetY - targetY
                        if (differenceX * differenceX + differenceY * differenceY > Buff_MAX_RANGE_SQUARE) then
                            set count = count - 1
                            call Target_Rip(count, d, e, otherTarget, target)
                        else
                            call MoveLightningEx(e.effectLightning, false, targetX, targetY, targetZ, otherTargetX, otherTargetY, GetUnitZ(otherTargetSelf, otherTargetX, otherTargetY) + GetUnitImpactZ(otherTarget))
                        endif
                        set iteration = iteration - 1
                        exitwhen (iteration < 0)
                    endloop
                endif
                set otherTargetSelf = null
            endfunction

            public function Target_Start takes Unit target, Unit otherTarget returns nothing
                local Target_Data d = Target_Data.create()
                local integer otherTargetId = otherTarget.id
                local unit otherTargetSelf = otherTarget.self
                local real otherTargetX = GetUnitX(otherTargetSelf)
                local real otherTargetY = GetUnitY(otherTargetSelf)
                local integer targetId = target.id
                local unit targetSelf = target.self
                local real targetX = GetUnitX(targetSelf)
                local real targetY = GetUnitY(targetSelf)
                local lightning effectLightning = AddLightningWJ(Target_EFFECT_LIGHTNING_PATH, targetX, targetY, GetUnitZ(targetSelf, targetX, targetY) + GetUnitOutpactZ(target), otherTargetX, otherTargetY, GetUnitZ(otherTargetSelf, otherTargetX, otherTargetY) + GetUnitImpactZ(otherTarget))
                set otherTargetSelf = null
                set targetSelf = null
                set d.effectLightning = effectLightning
                set d.otherTarget = otherTarget
                set d.target = target
                call AddIntegerToTableById(otherTargetId, Target_OTHER_TARGET_KEY, d)
                call AddIntegerToTableById(otherTargetId, Target_SCOPE_ID, d)
                call AddIntegerToTableById(targetId, Target_TARGET_KEY, d)
                call AddIntegerToTableById(targetId, Target_SCOPE_ID, d)
                //call SetLightningColor(effectLightning, 255, 255, 255, 255)
                set effectLightning = null
            endfunction
        //! runtextmacro Endscope()

        private function Buff_TargetEnding takes Unit target returns nothing
            local integer targetId = target.id
            call FlushAttachedIntegerById(targetId, Buff_SCOPE_ID)
            //! runtextmacro RemoveEventById( "targetId", "Buff_EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "targetId", "Buff_EVENT_DEATH" )
            call BJDebugMsg("target ending")
            call Target_Target_EndingByEnding(target)
            call BJDebugMsg("target ending2")
        endfunction

        private function Buff_Ending takes Buff_Data d, timer durationTimer returns nothing
            local integer count = d.targetsCount
            local integer iteration = count
            local Unit array targets
            local timer updateTimer = d.updateTimer
            call BJDebugMsg("all ending")
            loop
                set targets[iteration] = d.targets[iteration]
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call d.destroy()
            call FlushAttachedInteger(durationTimer, Buff_SCOPE_ID)
            call DestroyTimerWJ(durationTimer)
            loop
                call Buff_TargetEnding(targets[iteration])
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call FlushAttachedInteger(updateTimer, Buff_SCOPE_ID)
            call DestroyTimerWJ(updateTimer)
            set updateTimer = null
        endfunction

        public function Buff_Death takes Unit target returns nothing
            local integer count
            local Buff_Data d = GetAttachedIntegerById(target.id, Buff_SCOPE_ID)
            if (d != NULL) then
                set count = d.targetsCount - 1
                if (count == -1) then
                    call Buff_Ending(d, d.durationTimer)
                else
                    call Buff_TargetEnding(target)
                    set d.targetsCount = count
                endif
            endif
        endfunction

        private function Buff_Death_Event takes nothing returns nothing
            call Buff_Death(DYING_UNIT)
        endfunction

        private function Buff_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(durationTimer, Buff_SCOPE_ID)
            call Buff_Ending(d, durationTimer)
            set durationTimer = null
        endfunction

        private function Buff_RipTrig takes nothing returns nothing
            local Buff_Data d = Buff_RIP_TRIGGER_D
            local Unit target = Buff_RIP_TRIGGER_TARGET
            local integer count = d.targetsCount - 1
            if (count == -1) then
                call Buff_Ending(d, d.durationTimer)
            else
                call Buff_TargetEnding(target)
                set d.targetsCount = count
            endif
        endfunction

        public function Buff_Damage takes real damageAmount, Unit damageSource, Unit target returns real
            local Buff_Data d = GetAttachedIntegerById(target.id, Buff_SCOPE_ID)
            local integer iteration
            local Unit target2
            if (d != NULL) then
                set iteration = d.targetsCount
                set damageAmount = damageAmount / (iteration + 1)
                loop
                    set target2 = d.targets[iteration]
                    if (target2 != target) then
                        call UnitDamageUnitEx(damageSource, target2, damageAmount, null)
                    endif
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                endloop
            endif
            return damageAmount
        endfunction

        private function Buff_Damage_Event takes nothing returns nothing
            set DAMAGE_AMOUNT = Buff_Damage( DAMAGE_AMOUNT, DAMAGE_SOURCE, TRIGGER_UNIT )
        endfunction

        private function Buff_TargetConditions takes nothing returns boolean
            set FILTER_UNIT = GetUnit(GetFilterUnit())
            if (TargetConditions_Single(TEMP_PLAYER, FILTER_UNIT) == false) then
                return false
            endif
            if (GetAttachedIntegerById(FILTER_UNIT.id, Buff_SCOPE_ID) != NULL) then
                return false
            endif
            return true
        endfunction

        private function Buff_Update takes nothing returns nothing
            local timer updateTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(updateTimer, Buff_SCOPE_ID)
            local integer iteration = d.targetsCount
            loop
                call Target_Target_Update(d, d.targets[iteration])
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
        endfunction

        public function Buff_Start takes Unit caster, player casterOwner, unit target returns nothing
            local unit casterSelf = caster.self
            local integer count
            local Buff_Data d
            local timer durationTimer
            local Unit enumUnit
            local integer enumUnitId
            local unit enumUnitSelf
            local integer iteration
            local integer iteration2
            local Unit array targets
            local real targetX = GetUnitX(target)
            local real targetY = GetUnitY(target)
            local timer updateTimer
            set TEMP_PLAYER = casterOwner
            call GroupEnumUnitsInRangeWithCollision(Buff_ENUM_GROUP, targetX, targetY, Buff_AREA_RANGE, Buff_TARGET_CONDITIONS)
            if ((GetUnitState(casterSelf, UNIT_STATE_LIFE) > 0) and (GetAttachedIntegerById(caster.id, Buff_SCOPE_ID) == NULL)) then
                call GroupAddUnit(Buff_ENUM_GROUP, casterSelf)
            endif
            set casterSelf = null
            set enumUnitSelf = GetNearestUnit(Buff_ENUM_GROUP, targetX, targetY)
            if (enumUnitSelf != null) then
                set count = 0
                set d = Buff_Data.create()
                set durationTimer = CreateTimerWJ()
                set updateTimer = CreateTimerWJ()
                set iteration = 0
                set d.durationTimer = durationTimer
                set d.updateTimer = updateTimer
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    set enumUnitId = enumUnit.id
                    call GroupRemoveUnit(Buff_ENUM_GROUP, enumUnitSelf)
                    call AttachIntegerById(enumUnitId, Buff_SCOPE_ID, d)
                    //! runtextmacro AddEventById( "enumUnitId", "Buff_EVENT_DAMAGE" )
                    //! runtextmacro AddEventById( "enumUnitId", "Buff_EVENT_DEATH" )
                    set targets[iteration] = enumUnit
                    set d.targets[iteration] = targets[iteration]
                    if (iteration != 0) then
                        set iteration2 = count - 1
                        loop
                            call Target_Target_Start(enumUnit, targets[iteration2])
                            set iteration2 = iteration2 - 1
                            exitwhen (iteration2 < 0)
                        endloop
                    endif
                    set enumUnitSelf = FirstOfGroup(Buff_ENUM_GROUP)
                    exitwhen (enumUnitSelf == null)
                    set iteration = iteration + 1
                    exitwhen (iteration == Buff_MAX_TARGETS_AMOUNT)
                    set count = count + 1
                endloop
                if (iteration == Buff_MAX_TARGETS_AMOUNT) then
                    set enumUnitSelf = null
                endif
                set d.targetsCount = count
                call AttachInteger(durationTimer, Buff_SCOPE_ID, d)
                call AttachInteger(updateTimer, Buff_SCOPE_ID, d)
                call TimerStart(updateTimer, Buff_UPDATE_TIME, true, function Buff_Update)
                set updateTimer = null
                //call TimerStart(durationTimer, Buff_DURATION, false, function Buff_EndingByTimer)
                set durationTimer = null
            endif
        endfunction

        public function Buff_Init takes nothing returns nothing
            set Buff_ENUM_GROUP = CreateGroupWJ()
            //! runtextmacro CreateEvent( "Buff_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY", "1", "function Buff_Damage_Event" )
            //! runtextmacro CreateEvent( "Buff_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Buff_Death_Event" )
            set Buff_RIP_TRIGGER = CreateTriggerWJ()
            set Buff_TARGET_CONDITIONS = ConditionWJ( function Buff_TargetConditions )
            call AddTriggerCode(Buff_RIP_TRIGGER, function Buff_RipTrig)
        endfunction
    //! runtextmacro Endscope()

    private function Impact takes nothing returns nothing
        local player casterOwner
        local timer delayTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(delayTimer, FriendshipBracelet_SCOPE_ID)
        local Unit caster = d.caster
        local integer jumpsAmount
        local Unit target = d.target
        local unit targetSelf
        call Ending_Target(d, target)
        if (target == NULL) then
            call Ending( caster, d, delayTimer, false, NULL )
        else
            set casterOwner = caster.owner
            set targetSelf = target.self
            call Ending( caster, d, delayTimer, true, target )
            if ( TargetConditions_Single( casterOwner, target ) ) then
                call Buff_Buff_Start(caster, casterOwner, targetSelf)
            endif
            set casterOwner = null
            set targetSelf = null
        endif
        set delayTimer = null
    endfunction

    public function Decay takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById(targetId, FriendshipBracelet_SCOPE_ID)
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById(targetId, FriendshipBracelet_SCOPE_ID, iteration)
                call Ending_Target(d, target)
                set d.target = NULL
                set iteration = iteration - 1
                exitwhen (iteration < TABLE_STARTED)
            endloop
        endif
    endfunction

    private function Decay_Event takes nothing returns nothing
        call Decay(TRIGGER_UNIT)
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local Data d = Data.create()
        local timer delayTimer = CreateTimerWJ()
        local integer targetId = target.id
        //call DestroyLightningTimedEx( AddLightningBetweenUnits( EFFECT_LIGHTNING_PATH, caster, target ), EFFECT_LIGHTNING_DURATION )
        set d.caster = caster
        set d.delayTimer = delayTimer
        set d.target = target
        call AddUnitRemainingReference( caster )
        call AttachInteger( delayTimer, FriendshipBracelet_SCOPE_ID, d )
        call AddIntegerToTableById(targetId, FriendshipBracelet_SCOPE_ID, d)
        if (CountIntegersInTableById(targetId, FriendshipBracelet_SCOPE_ID) == TABLE_STARTED) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DECAY" )
        endif
        call TimerStart( delayTimer, JUMP_DELAY, false, function Impact )
        set delayTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 75)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 60)
        call SetItemTypeRefreshIntervalStart(d, 160)

        //! runtextmacro CreateEvent( "EVENT_DECAY", "UnitFinishesDecaying_EVENT_KEY", "0", "function Decay_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Buff_Buff_Init()
    endfunction
//! runtextmacro Endscope()