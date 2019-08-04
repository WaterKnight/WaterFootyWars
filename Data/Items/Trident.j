//TESH.scrollpos=98
//TESH.alwaysfold=0
//! runtextmacro Scope("Trident")
    globals
        public constant integer ITEM_ID = 'I01V'

        private constant real BONUS_ARMOR = 3.
        private constant real BONUS_DAMAGE = 5.
        private constant real CHANCE = 0.2
    endglobals

    private struct Data
        integer amount
    endstruct

    public function Drop takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, Trident_SCOPE_ID)
        local integer amount = d.amount - 1
        if (amount == NULL) then
            call d.destroy()
            call FlushAttachedIntegerById( manipulatingUnitId, Trident_SCOPE_ID )
            //! runtextmacro RemoveEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = amount
        endif
        call AddUnitArmorBonus( manipulatingUnit, -BONUS_ARMOR )
        call AddUnitDamageBonus( manipulatingUnit, -BONUS_DAMAGE )
    endfunction

    //! runtextmacro Scope("Knockback")
        globals
            private constant real Knockback_DURATION = 0.75
            private SoundType array Knockback_EFFECT_SOUND_TYPES
            private constant real Knockback_SPEED_ADD = -300. * Knockback_DURATION
            private constant real Knockback_SPEED = 450. * Knockback_DURATION
            private constant string Knockback_TARGET_EFFECT_PATH = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
            private constant string Knockback_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
            private constant real Knockback_UPDATE_TIME = 0.035
            private constant real Knockback_LENGTH = Knockback_SPEED * Knockback_UPDATE_TIME
            private constant real Knockback_LENGTH_ADD = Knockback_SPEED * Knockback_UPDATE_TIME
        endglobals

        private struct Knockback_Data
            timer durationTimer
            real lengthX
            real lengthY
            Unit target
            timer updateTimer
        endstruct

        private function Knockback_Ending takes Knockback_Data d, timer durationTimer, Unit target returns nothing
            local integer targetId = target.id
            local timer updateTimer = d.updateTimer
            call d.destroy()
            call FlushAttachedInteger(durationTimer, Knockback_SCOPE_ID)
            call DestroyTimerWJ(durationTimer)
            call FlushAttachedIntegerById(targetId, Knockback_SCOPE_ID)
            call RemoveIntegerFromTableById(targetId, Knockback_SCOPE_ID, d)
            if (CountIntegersInTableById(targetId, Knockback_SCOPE_ID) == TABLE_EMPTY) then
                //! runtextmacro RemoveEventById( "targetId", "Knockback_EVENT_DEATH" )
            endif
            call FlushAttachedInteger(updateTimer, Knockback_SCOPE_ID)
            call DestroyTimerWJ(updateTimer)
            set updateTimer = null
        endfunction

        public function Knockback_Death takes Unit target returns nothing
            local Knockback_Data d
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById(targetId, Knockback_SCOPE_ID)
            if (iteration > TABLE_EMPTY) then
                loop
                    set d = GetIntegerFromTableById(targetId, Knockback_SCOPE_ID, iteration)
                    call Knockback_Ending(d, d.durationTimer, target)
                    set iteration = iteration - 1
                    exitwhen (iteration < TABLE_STARTED)
                endloop
            endif
        endfunction

        private function Knockback_Death_Event takes nothing returns nothing
            call Knockback_Death(DYING_UNIT)
        endfunction

        private function Knockback_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Knockback_Data d = GetAttachedInteger(durationTimer, Knockback_SCOPE_ID)
            call Knockback_Ending(d, durationTimer, d.target)
            set durationTimer = null
        endfunction

        private function Knockback_Move takes nothing returns nothing
            local timer updateTimer = GetExpiredTimer()
            local Knockback_Data d = GetAttachedInteger(updateTimer, Knockback_SCOPE_ID)
            local unit target = d.target.self
            local real targetX = GetUnitX(target)
            local real targetY = GetUnitY(target)
            set updateTimer = null
            call DestroyEffectWJ(AddSpecialEffectTargetWJ(Knockback_TARGET_EFFECT_PATH, target, Knockback_TARGET_EFFECT_ATTACHMENT_POINT))
            //if ((IsUnitType(target, UNIT_TYPE_FLYING) and (IsTerrainPathable( newX, newY, PATHING_TYPE_WALKABILITY ) == false)) or (IsUnitType(target, UNIT_TYPE_GROUND) and (IsTerrainPathable( newX, newY, PATHING_TYPE_FLYABILITY ) == false))) then
                call SetUnitXYIfNotBlocked( target, targetX, targetY, targetX + d.lengthX, targetY + d.lengthY )
            //endif
            set target = null
        endfunction

        public function Knockback_Start takes Unit caster, Unit target returns nothing
            local unit casterSelf = caster.self
            local Knockback_Data d = Knockback_Data.create()
            local timer durationTimer = CreateTimerWJ()
            local integer targetId = target.id
            local unit targetSelf = target.self
            local real angle = Atan2(GetUnitY(targetSelf) - GetUnitY(casterSelf), GetUnitX(targetSelf) - GetUnitX(casterSelf))
            local timer updateTimer = CreateTimerWJ()
            set casterSelf = null
            set d.durationTimer = durationTimer
            set d.lengthX = Knockback_LENGTH * Cos(angle)
            set d.lengthY = Knockback_LENGTH * Sin(angle)
            set d.target = target
            set d.updateTimer = updateTimer
            call AttachInteger(durationTimer, Knockback_SCOPE_ID, d)
            call AddIntegerToTableById(targetId, Knockback_SCOPE_ID, d)
            if (CountIntegersInTableById(targetId, Knockback_SCOPE_ID) == TABLE_STARTED) then
                //! runtextmacro AddEventById( "targetId", "Knockback_EVENT_DEATH" )
            endif
            call AttachInteger(updateTimer, Knockback_SCOPE_ID, d)
            call PlaySoundFromTypeOnUnit( Knockback_EFFECT_SOUND_TYPES[GetRandomInt(0, 2)], targetSelf )
            set targetSelf = null
            call TimerStart(updateTimer, Knockback_UPDATE_TIME, true, function Knockback_Move)
            set updateTimer = null
            call TimerStart(durationTimer, Knockback_DURATION, true, function Knockback_EndingByTimer)
            set durationTimer = null
        endfunction

        public function Knockback_Init takes nothing returns nothing
            set Knockback_EFFECT_SOUND_TYPES[0] = TRIDENT_SOUND_TYPE
            set Knockback_EFFECT_SOUND_TYPES[1] = TRIDENT_SOUND1_TYPE
            set Knockback_EFFECT_SOUND_TYPES[2] = TRIDENT_SOUND2_TYPE
            //! runtextmacro CreateEvent( "Knockback_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Knockback_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    private function Conditions takes Unit manipulatingUnit, player manipulatingUnitOwner, unit target returns boolean
        if ( GetAttachedIntegerById( manipulatingUnit.id, Trident_SCOPE_ID ) == NULL ) then
            return false
        endif
        if ( IsUnitAlly( target, manipulatingUnitOwner ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetRandomReal( 0.01, 1 ) > CHANCE ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit manipulatingUnit, Unit target returns nothing
        if ( Conditions( manipulatingUnit, manipulatingUnit.owner, target.self ) ) then
            call Knockback_Knockback_Start(manipulatingUnit, target)
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, Trident_SCOPE_ID)
        if (d == NULL) then
            set d = Data.create()
            set d.amount = 1
            call AttachIntegerById( manipulatingUnitId, Trident_SCOPE_ID, d )
            //! runtextmacro AddEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = d.amount + 1
        endif
        call AddUnitArmorBonus( manipulatingUnit, BONUS_ARMOR )
        call AddUnitDamageBonus( manipulatingUnit, BONUS_DAMAGE )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 600)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 240)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        call Knockback_Knockback_Init()
    endfunction
//! runtextmacro Endscope()