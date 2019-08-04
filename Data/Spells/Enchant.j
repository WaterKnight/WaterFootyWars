//TESH.scrollpos=77
//TESH.alwaysfold=0
//! runtextmacro Scope("Enchant")
    globals
        private constant integer ORDER_ID = 852096//OrderId( "thunderclap" )
        public constant integer SPELL_ID = 'A06P'

        private constant real AREA_RANGE = 250.
        private constant real BONUS_DAMAGE = 5.
        private constant real DAMAGE_FACTOR = 0.55
        private constant string DAMAGE_SPECIAL_EFFECT_PATH = "Abilities\\Weapons\\GyroCopter\\GyroCopterMissile.mdl"
        private constant string DAMAGE_SPECIAL_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string DAMAGE_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\Volcano\\VolcanoMissile.mdl"
        private constant string DAMAGE_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private boolexpr DAMAGE_TARGET_CONDITIONS
        private constant real DURATION = 15.
        private group ENUM_GROUP
        private constant string TARGET_EFFECT_PATH = "Abilities\\Weapons\\PhoenixMissile\\Phoenix_Missile_mini.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "weapon"
    endglobals

    private struct Data
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, Enchant_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, Enchant_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DAMAGE" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitDamageBonus( target, -BONUS_DAMAGE )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, Enchant_SCOPE_ID)
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
        local Data d = GetAttachedInteger(durationTimer, Enchant_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function Damage_TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_GROUND ) != TEMP_BOOLEAN ) then
            return false
        endif
        if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes real damageAmount, Unit target, Unit victim returns nothing
        local Data d = GetAttachedIntegerById(target.id, Enchant_SCOPE_ID)
        local unit enumUnit
        local unit victimSelf
        if ( d != NULL ) then
            set victimSelf = victim.self
            set TEMP_BOOLEAN = IsUnitType( victimSelf, UNIT_TYPE_GROUND )
            set TEMP_PLAYER = target.owner
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( DAMAGE_TARGET_EFFECT_PATH, victimSelf, DAMAGE_TARGET_EFFECT_ATTACHMENT_POINT ) )
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, GetUnitX( victimSelf ), GetUnitY( victimSelf ), AREA_RANGE, DAMAGE_TARGET_CONDITIONS )
            set victimSelf = null
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            if ( enumUnit != null ) then
                set damageAmount = damageAmount * DAMAGE_FACTOR
                loop
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call DestroyEffectWJ( AddSpecialEffectTargetWJ( DAMAGE_SPECIAL_EFFECT_PATH, enumUnit, DAMAGE_SPECIAL_EFFECT_ATTACHMENT_POINT ) )
                    call UnitDamageUnitBySpell( target, GetUnit(enumUnit), damageAmount )
                    set enumUnit = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_AMOUNT, DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function SpellEffect takes Unit target returns nothing
        local timer durationTimer
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, Enchant_SCOPE_ID)
        local unit targetSelf = target.self
        local real targetX = GetUnitX(targetSelf)
        local real targetY = GetUnitY(targetSelf)
        if ( d == NULL ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.target = target
            call AttachInteger(durationTimer, Enchant_SCOPE_ID, d)
            call AttachIntegerById(targetId, Enchant_SCOPE_ID, d)
            //! runtextmacro AddEventById( "targetId", "EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
            call AddUnitDamageBonus( target, BONUS_DAMAGE )
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        call PlaySoundFromTypeAtPosition( ENCHANT_SOUND_TYPE, targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) )
        set targetSelf = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) == false ) then
            return ErrorStrings_ONLY_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( IsUnitIllusionWJ( target ) ) then
            return ErrorStrings_NOT_ILLUSION
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        set DAMAGE_TARGET_CONDITIONS = ConditionWJ( function Damage_TargetConditions )
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call InitEffectType( DAMAGE_SPECIAL_EFFECT_PATH )
        call InitEffectType( DAMAGE_TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()