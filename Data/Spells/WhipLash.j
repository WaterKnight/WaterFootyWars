//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("WhipLash")
    globals
        private constant integer ORDER_ID = 852129//OrderId( "windwalk" )
        public constant integer SPELL_ID = 'A07O'

        private constant real AREA_RANGE = 525.
        private constant real BONUS_RELATIVE_ATTACK_RATE = 0.25
        private constant real BONUS_RELATIVE_SPEED = 0.5
        private constant real DURATION = 10.
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIsp\\SpeedTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        real bonusSpeed
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local real bonusSpeed = -d.bonusSpeed
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, WhipLash_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, WhipLash_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitAttackRate( target, -BONUS_RELATIVE_ATTACK_RATE )
        call AddUnitSpeedBonus( target, bonusSpeed )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, WhipLash_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, WhipLash_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitWard( GetUnit(FILTER_UNIT_SELF) ) ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local real bonusSpeed
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d
        local timer durationTimer
        local Unit enumUnit
        local integer enumUnitId
        local unit enumUnitSelf
        local boolean isNew
        local real oldBonusSpeed
        call PlaySoundFromTypeAtPosition( WHIP_LASH_SOUND_TYPE, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        set casterSelf = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision(ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS)
        set enumUnitSelf = FirstOfGroup(ENUM_GROUP)
        if (enumUnitSelf != null) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                set bonusSpeed = GetUnitSpeed( enumUnit ) * BONUS_RELATIVE_SPEED
                set enumUnitId = enumUnit.id
                set d = GetAttachedIntegerById(enumUnitId, WhipLash_SCOPE_ID)
                set isNew = ( d == NULL )
                call GroupRemoveUnit(ENUM_GROUP, enumUnitSelf)
                if ( isNew ) then
                    set d = Data.create()
                    set durationTimer = CreateTimerWJ()
                    set d.durationTimer = durationTimer
                    set d.target = enumUnit
                    call AttachInteger( durationTimer, WhipLash_SCOPE_ID, d )
                    call AttachIntegerById( enumUnitId, WhipLash_SCOPE_ID, d )
                    //! runtextmacro AddEventById( "enumUnitId", "EVENT_DEATH" )
                    //! runtextmacro AddEventById( "enumUnitId", "EVENT_DISPEL" )
                else
                    set durationTimer = d.durationTimer
                    set oldBonusSpeed = d.bonusSpeed
                    call DestroyEffectWJ( d.targetEffect )
                endif
                set d.bonusSpeed = bonusSpeed
                set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnitSelf, TARGET_EFFECT_ATTACHMENT_POINT )
                if ( isNew ) then
                    call AddUnitAttackRate( enumUnit, BONUS_RELATIVE_ATTACK_RATE )
                    call AddUnitSpeedBonus( enumUnit, bonusSpeed )
                else
                    call AddUnitSpeedBonus( enumUnit, bonusSpeed - oldBonusSpeed )
                endif
                call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
                set enumUnitSelf = FirstOfGroup(ENUM_GROUP)
                exitwhen (enumUnitSelf == null)
            endloop
        endif
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        set TARGET_CONDITIONS = ConditionWJ(function TargetConditions)
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()