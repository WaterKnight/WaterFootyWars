//TESH.scrollpos=137
//TESH.alwaysfold=0
//! runtextmacro Scope("ScrollOfRage")
    globals
        public constant integer ITEM_ID = 'I007'
        public constant integer SPELL_ID = 'A01B'

        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl"
        private constant real AREA_RANGE = 500.
        private constant real BONUS_RELATIVE_DAMAGE = 0.4
        private constant real BONUS_RELATIVE_SPEED = 0.3
        private constant real DURATION = 45.
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
    endglobals

    private struct Data
        real bonusDamage
        real bonusSpeed
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local real bonusDamage = d.bonusDamage
        local real bonusSpeed = d.bonusSpeed
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, ScrollOfRage_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, ScrollOfRage_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitDamageBonus( target, -bonusDamage )
        call AddUnitSpeedBonus( target, -bonusSpeed )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, ScrollOfRage_SCOPE_ID)
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
        local Data d = GetAttachedInteger(durationTimer, ScrollOfRage_SCOPE_ID)
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
        return true
    endfunction

    private function StartTarget takes Unit target returns nothing
        local real bonusDamage = (GetUnitDamage( target ) + GetUnitTypeDamageDices( target.type )) * BONUS_RELATIVE_DAMAGE
        local real bonusSpeed = GetUnitSpeed( target ) * BONUS_RELATIVE_SPEED
        local timer durationTimer
        local real oldBonusDamage
        local real oldBonusSpeed
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById( targetId, ScrollOfRage_SCOPE_ID )
        local boolean isNew = (d == NULL)
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.target = target
            call AttachInteger( durationTimer, ScrollOfRage_SCOPE_ID, d )
            call AttachIntegerById( targetId, ScrollOfRage_SCOPE_ID, d )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        else
            set durationTimer = d.durationTimer
            set oldBonusDamage = d.bonusDamage
            set oldBonusSpeed = d.bonusSpeed
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.bonusDamage = bonusDamage
        set d.bonusSpeed = bonusSpeed
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, target.self, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call AddUnitDamageBonus( target, bonusDamage )
            call AddUnitSpeedBonus( target, bonusSpeed )
        else
            call AddUnitDamageBonus( target, bonusDamage - oldBonusDamage )
            call AddUnitSpeedBonus( target, bonusSpeed - oldBonusSpeed )
        endif
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
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
                call StartTarget(GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 500)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 80)
        call SetItemTypeRefreshIntervalStart(d, 200)

        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()