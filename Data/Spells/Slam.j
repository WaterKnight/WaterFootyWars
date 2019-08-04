//TESH.scrollpos=135
//TESH.alwaysfold=0
//! runtextmacro Scope("Slam")
    globals
        public constant integer ORDER_ID = 852127//OrderId("stomp")
        public constant integer RESEARCH_ID = 'R01K'
        public constant integer SPELL_ID = 'A08B'

        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
        private constant real AREA_RANGE = 175.
        private constant real BONUS_RELATIVE_SPEED = -0.5
        private constant real DAMAGE = 30.
        private constant real DURATION = 7.5
        private group ENUM_GROUP
        private constant real HERO_DURATION = 4.
        private constant real RELATIVE_BONUS_ATTACK_RATE = -0.5
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
    endglobals

    private struct Data
        real bonusSpeed
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local real bonusSpeed = d.bonusSpeed
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, Slam_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, Slam_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitAttackRate( target, -RELATIVE_BONUS_ATTACK_RATE )
        call AddUnitSpeedBonus( target, -bonusSpeed )
    endfunction

    public function Death takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, Slam_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Slam_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_FLYING ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    private function StartTarget takes Unit caster, Unit target returns nothing
        local real bonusSpeed = GetUnitSpeed( target ) * BONUS_RELATIVE_SPEED
        local real duration
        local timer durationTimer
        local real oldBonusSpeed
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById( targetId, Slam_SCOPE_ID )
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.target = target
            call AttachInteger( durationTimer, Slam_SCOPE_ID, d )
            call AttachIntegerById( targetId, Slam_SCOPE_ID, d )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        else
            set durationTimer = d.durationTimer
            set oldBonusSpeed = d.bonusSpeed
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.bonusSpeed = bonusSpeed
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call AddUnitAttackRate( target, RELATIVE_BONUS_ATTACK_RATE )
            call AddUnitSpeedBonus( target, bonusSpeed )
        else
            call AddUnitSpeedBonus( target, bonusSpeed - oldBonusSpeed )
        endif
        if (IsUnitType(targetSelf, UNIT_TYPE_HERO)) then
            set duration = HERO_DURATION
        else
            set duration = DURATION
        endif
        set targetSelf = null
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
        call UnitDamageUnitEx( caster, target, DAMAGE, null )
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local unit enumUnit
        set casterSelf = null
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, casterX, casterY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if (enumUnit != null) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call StartTarget(caster, GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ResearchType d = InitResearchType( RESEARCH_ID )
        call SetResearchTypeGoldCost(d, 1, 300)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()