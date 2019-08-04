//TESH.scrollpos=351
//TESH.alwaysfold=0
//! runtextmacro Scope("AdvertisingGift")
    globals
        private constant integer ORDER_ID = 852662//OrderId( "acidbomb" )
        public constant integer SPELL_ID = 'A02Y'

        private constant string AREA_EFFECT_PATH = ""
        private real array AREA_RANGE
        private real array BONUS_SPEED
        private real array BONUS_SPEED_PER_AGILITY_POINT
        private constant real CEILING = 200.
        private real array DAMAGE
        private constant integer DUMMY_UNIT_ID = 'n010'
        private real array DURATION
        private group ENUM_GROUP
        private constant integer LEVELS_AMOUNT = 5
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.035
    endglobals

    private struct Data
        integer abilityLevel
        real bonusSpeed
        Unit caster
        unit dummyUnit
        real lengthX
        real lengthY
        real lengthZ
        real lengthZAdd
        timer moveTimer
        real targetX
        real targetY
        real targetZ
    endstruct

    //! runtextmacro Scope("Target")
        globals
            private real array Target_DURATION
            private real array Target_HERO_DURATION
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            integer abilityLevel
            real array bonusSpeed[LEVELS_AMOUNT]
            timer array durationTimer[LEVELS_AMOUNT]
            Unit target
            effect targetEffect
        endstruct

        private function Target_Ending takes Target_Data d, timer durationTimer, Unit target returns nothing
            local integer abilityLevel = d.abilityLevel
            local real bonusSpeed
            local integer iteration = abilityLevel - 1
            local effect targetEffect
            local integer targetId
            loop
                exitwhen (durationTimer == d.durationTimer[iteration])
                set iteration = iteration - 1
            endloop
            set d.durationTimer[iteration] = null
            if ( iteration > abilityLevel ) then
                set bonusSpeed = d.bonusSpeed[abilityLevel]
                loop
                    exitwhen (iteration < 0)
                    exitwhen (d.durationTimer[iteration] != null)
                    set iteration = iteration - 1
                endloop
                if ( iteration > -1 ) then
                    set d.abilityLevel = iteration + 1
                    call AddUnitSpeedBonus( target, d.bonusSpeed[iteration] - bonusSpeed )
                else
                    set targetEffect = d.targetEffect
                    set targetId = target.id
                    call d.destroy()
                    call DestroyEffectWJ( targetEffect )
                    set targetEffect = null
                    call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                    //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                    //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DISPEL" )
                    call AddUnitSpeedBonus( target, -bonusSpeed )
                endif
            endif
            call FlushAttachedInteger( durationTimer, Target_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
        endfunction

        public function Target_Dispel takes Unit target returns nothing
            local integer abilityLevel
            local Target_Data d = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            local timer durationTimer
            local integer iteration
            if (d != NULL) then
                set abilityLevel = d.abilityLevel
                set iteration = 0
                loop
                    set durationTimer = d.durationTimer[iteration]
                    if ( durationTimer != null ) then
                        call Target_Ending( d, durationTimer, target )
                    endif
                    set iteration = iteration + 1
                    exitwhen ( iteration >= abilityLevel )
                endloop
                set durationTimer = null
            endif
        endfunction

        private function Target_Dispel_Event takes nothing returns nothing
            call Target_Dispel( TRIGGER_UNIT )
        endfunction

        public function Target_Death takes Unit target returns nothing
            call Target_Dispel( target )
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        private function Target_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Target_Data d = GetAttachedInteger(durationTimer, Target_SCOPE_ID)
            call Target_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        public function Target_Start takes integer abilityLevel, real bonusSpeed, Unit target returns nothing
            local real duration
            local timer durationTimer
            local integer oldAbilityLevel
            local real oldBonusSpeed
            local integer iteration
            local integer targetId = target.id
            local Target_Data d = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
            local boolean isNew = (d == NULL)
            local unit targetSelf = target.self
            if ( isNew ) then
                set d = Target_Data.create()
                set durationTimer = CreateTimerWJ()
                set iteration = LEVELS_AMOUNT - 1
                set d.abilityLevel = abilityLevel
                set d.target = target
                loop
                    if (iteration == abilityLevel) then
                        set d.durationTimer[iteration] = durationTimer
                    else
                        set d.durationTimer[iteration] = null
                    endif
                    set iteration = iteration - 1
                    exitwhen (iteration < 0)
                endloop
                call AttachInteger(durationTimer, Target_SCOPE_ID, d)
                call AttachIntegerById(targetId, Target_SCOPE_ID, d)
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DISPEL" )
            else
                set durationTimer = d.durationTimer[abilityLevel]
                if (durationTimer == null) then
                    set durationTimer = CreateTimerWJ()
                    set d.durationTimer[abilityLevel] = durationTimer
                    call AttachInteger(durationTimer, Target_SCOPE_ID, d)
                endif
                set oldAbilityLevel = d.abilityLevel
                set oldBonusSpeed = d.bonusSpeed[oldAbilityLevel - 1]
                call DestroyEffectWJ( d.targetEffect )
            endif
            set d.bonusSpeed[abilityLevel - 1] = bonusSpeed
            set d.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, targetSelf, Target_TARGET_EFFECT_ATTACHMENT_POINT )
            if ( isNew ) then
                call AddUnitSpeedBonus( target, bonusSpeed )
            elseif (abilityLevel >= oldAbilityLevel) then
                set d.abilityLevel = abilityLevel
                call AddUnitSpeedBonus( target, bonusSpeed - oldBonusSpeed )
            endif
            if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                set duration = Target_HERO_DURATION[abilityLevel]
            else
                set duration = Target_DURATION[abilityLevel]
            endif
            set targetSelf = null
            call TimerStart( durationTimer, duration, false, function Target_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Target_Init takes nothing returns nothing
            set Target_DURATION[1] = 10
            set Target_DURATION[2] = 10
            set Target_DURATION[3] = 10
            set Target_DURATION[4] = 10
            set Target_DURATION[5] = 10
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            //! runtextmacro CreateEvent( "Target_EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Target_Dispel_Event" )
            set Target_HERO_DURATION[1] = 5
            set Target_HERO_DURATION[2] = 5
            set Target_HERO_DURATION[3] = 5
            set Target_HERO_DURATION[4] = 5
            set Target_HERO_DURATION[5] = 5
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Ending takes nothing returns nothing
        local real damageAmount
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, AdvertisingGift_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local real bonusSpeed = d.bonusSpeed
        local Unit enumUnit
        local unit enumUnitSelf
        local timer moveTimer = d.moveTimer
        local Unit caster = d.caster
        local unit dummyUnit = d.dummyUnit
        local real targetX = d.targetX
        local real targetY = d.targetY
        local real targetZ = d.targetZ
        call d.destroy()
        call FlushAttachedReal( durationTimer, AdvertisingGift_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call SetUnitX( dummyUnit, targetX )
        call SetUnitY( dummyUnit, targetY )
        call SetUnitZ( dummyUnit, targetX, targetY, targetZ )
        call SetUnitAnimationByIndex( dummyUnit, 0 )
        call RemoveUnitTimed( dummyUnit, 2 )
        set dummyUnit = null
        call FlushAttachedInteger( moveTimer, AdvertisingGift_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        set moveTimer = null
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX, targetY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            set damageAmount = DAMAGE[abilityLevel]
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call Target_Target_Start(abilityLevel, bonusSpeed, enumUnit)
                call UnitDamageUnitBySpell( caster, enumUnit, damageAmount )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
    endfunction

    private function Move takes nothing returns nothing
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, AdvertisingGift_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local real dummyUnitX = GetUnitX(dummyUnit)
        local real dummyUnitY = GetUnitY(dummyUnit)
        local real lengthZ = d.lengthZ + d.lengthZAdd
        local real newX = dummyUnitX + d.lengthX
        local real newY = dummyUnitY + d.lengthY
        local real newZ = GetUnitZ(dummyUnit, dummyUnitX, dummyUnitY) + lengthZ
        set d.lengthZ = lengthZ
        call SetUnitX( dummyUnit, newX )
        call SetUnitY( dummyUnit, newY )
        call SetUnitZ( dummyUnit, newX, newY, newZ )
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local real ceiling
        local Data d = Data.create()
        local unit dummyUnit
        local real duration = DURATION[abilityLevel]
        local timer durationTimer = CreateTimerWJ()
        local real length
        local real lengthZ
        local timer moveTimer = CreateTimerWJ()
        local real targetZ = GetFloorHeight( targetX, targetY )
        if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
            set length = DistanceByCoordinates( casterX, casterY, targetX, targetY ) / duration * UPDATE_TIME
        else
            set angle = GetUnitFacingWJ( casterSelf )
            set length = 0
        endif
        set casterSelf = null
        if ( casterZ > targetZ ) then
            set ceiling = CEILING + casterZ
        else
            set ceiling = CEILING + targetZ
        endif
        set lengthZ = ( 2 * ceiling + 2 * SquareRoot( ceiling * ( ceiling + casterZ - targetZ ) ) ) / duration * UPDATE_TIME
        set dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, angle )
        set d.abilityLevel = abilityLevel
        set d.bonusSpeed = BONUS_SPEED[abilityLevel] + GetHeroAgilityTotal( caster ) * BONUS_SPEED_PER_AGILITY_POINT[abilityLevel]
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.lengthX = length * Cos(angle)
        set d.lengthY = length * Sin(angle)
        set d.lengthZ = lengthZ
        set d.lengthZAdd = -0.5 * lengthZ * lengthZ / ceiling
        set d.moveTimer = moveTimer
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
        call AttachInteger( durationTimer, AdvertisingGift_SCOPE_ID, d )
        call AttachInteger( moveTimer, AdvertisingGift_SCOPE_ID, d )
        call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
        call TimerStart( durationTimer, duration, false, function Ending )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Order takes Unit caster, real targetX, real targetY returns string
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 300
        set AREA_RANGE[2] = 300
        set AREA_RANGE[3] = 300
        set AREA_RANGE[4] = 300
        set AREA_RANGE[5] = 300
        set BONUS_SPEED[1] = -50
        set BONUS_SPEED[2] = -70
        set BONUS_SPEED[3] = -90
        set BONUS_SPEED[4] = -105
        set BONUS_SPEED[5] = -120
        set BONUS_SPEED_PER_AGILITY_POINT[1] = -1
        set BONUS_SPEED_PER_AGILITY_POINT[2] = -1
        set BONUS_SPEED_PER_AGILITY_POINT[3] = -1
        set BONUS_SPEED_PER_AGILITY_POINT[4] = -1
        set BONUS_SPEED_PER_AGILITY_POINT[5] = -1
        set DAMAGE[1] = 30
        set DAMAGE[2] = 40
        set DAMAGE[3] = 50
        set DAMAGE[4] = 60
        set DAMAGE[5] = 70
        set ENUM_GROUP = CreateGroupWJ()
        set DURATION[1] = 1.5
        set DURATION[2] = 1.5
        set DURATION[3] = 1.5
        set DURATION[4] = 1.5
        set DURATION[5] = 1.5
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()