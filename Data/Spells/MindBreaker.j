//TESH.scrollpos=218
//TESH.alwaysfold=0
//! runtextmacro Scope("MindBreaker")
    globals
        private constant integer ORDER_ID = 852179//OrderId( "manaburn" )
        public constant integer SPELL_ID = 'A00J'

        private real array AREA_DAMAGE
        private real array AREA_DAMAGE_PER_INTELLIGENCE_POINT
        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
        private constant string AREA_EFFECT2_PATH = "Units\\NightElf\\Wisp\\WispExplode.mdl"
        private real array AREA_RANGE
        private real array DAMAGE
        private real array DAMAGE_PER_STRENGTH_POINT
        private constant integer DUMMY_UNIT_ID = 'O009'
        private real array DESTROYED_MANA
        private real array DURATION
        private real array DURATION_PER_MANA_POINT
        private constant real EFFECT_INTERVAL = 0.75
        private constant real EFFECT_DURATION = (3 + 1) * EFFECT_INTERVAL
        private group ENUM_GROUP
        private real array HERO_DURATION
        private real array HERO_DURATION_PER_MANA_POINT
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
        private constant string TARGET_EFFECT2_PATH = "Abilities\\Spells\\Undead\\AbsorbMana\\AbsorbManaBirthMissile.mdl"
        private constant string TARGET_EFFECT2_ATTACHMENT_POINT = "chest"
    endglobals

    private struct Data
        timer durationTimer
        timer intervalTimer
        Unit target
    endstruct

    public function Channel takes Unit caster, Unit target returns nothing
        local real angle
        local real angleAdd = PI / 1.5
        local playercolor casterColor = GetPlayerColor(caster.owner)
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local unit dummyUnit
        local integer iteration = 1
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        set targetSelf = null
        if ((casterX != targetX) or (casterY != targetY)) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ(casterSelf)
        endif
        set casterSelf = null
        set angle = angle + PI / 3
        loop
            set angle = angle + angleAdd
            set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, targetX - 100 * Cos( angle ), targetY - 100 * Sin( angle ), angle )
            call SetUnitColor( dummyUnit, casterColor )
            call SetUnitTimeScale( dummyUnit, 1.5 )
            call SetUnitVertexColor( dummyUnit, 255, 255, 255, 127 )
            call SetUnitAnimationByIndex( dummyUnit, 2 )
            call RemoveUnitTimed( dummyUnit, 0.75 )
            set iteration = iteration + 1
            exitwhen ( iteration > 3 )
        endloop
        set casterColor = null
        set dummyUnit = null
    endfunction

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer targetId = target.id
        local timer intervalTimer = d.intervalTimer
        call d.destroy()
        call FlushAttachedInteger( durationTimer, MindBreaker_SCOPE_ID )
        call DestroyTimerWJ(durationTimer)
        call FlushAttachedInteger( intervalTimer, MindBreaker_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
        call RemoveIntegerFromTableById( targetId, MindBreaker_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, MindBreaker_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, target.self, TARGET_EFFECT2_ATTACHMENT_POINT ) )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, MindBreaker_SCOPE_ID)
        call Ending(d, durationTimer, d.target)
        set durationTimer = null
    endfunction

    public function Death takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, MindBreaker_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, MindBreaker_SCOPE_ID, iteration )
                call Ending( d, d.durationTimer, target )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function Interval takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, MindBreaker_SCOPE_ID)
        local Unit target = d.target
        local unit targetSelf = target.self
        set intervalTimer = null
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, targetSelf, TARGET_EFFECT2_ATTACHMENT_POINT ) )
        set targetSelf = null
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
        if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
            return false
        endif
        return true
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local real areaDamageAmount
        local Data d = Data.create()
        local real duration
        local timer durationTimer = CreateTimerWJ()
        local unit enumUnit
        local timer intervalTimer = CreateTimerWJ()
        local integer targetId = target.id
        local unit targetSelf = target.self
        local real destroyedMana = Min(GetUnitState( targetSelf, UNIT_STATE_MANA ), DESTROYED_MANA[abilityLevel])
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        call Whirlwind_Death( caster )
        if ( GetUnitState( targetSelf, UNIT_STATE_MAX_MANA ) > 0 ) then
            call AddUnitState( targetSelf, UNIT_STATE_MANA, -destroyedMana )
        endif
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX, targetY ) )
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT2_PATH, targetX, targetY ) )
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, targetSelf, TARGET_EFFECT2_ATTACHMENT_POINT ) )
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        set d.target = target
        call AttachInteger( durationTimer, MindBreaker_SCOPE_ID, d )
        call AttachInteger( intervalTimer, MindBreaker_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, MindBreaker_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, MindBreaker_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call TimerStart( intervalTimer, EFFECT_INTERVAL, true, function Interval )
        set intervalTimer = null
        call TimerStart( durationTimer, EFFECT_DURATION, true, function EndingByTimer )
        set durationTimer = null
        if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION[abilityLevel] + destroyedMana * HERO_DURATION_PER_MANA_POINT[abilityLevel]
        else
            set duration = DURATION[abilityLevel] + destroyedMana * DURATION_PER_MANA_POINT[abilityLevel]
        endif
        if ( IsUnitIllusionWJ( target ) ) then
            call KillUnit( targetSelf )
        else
            call SetUnitStunTimed( target, 1, duration )
            call UnitDamageUnitEx( caster, target, DAMAGE[abilityLevel] + GetHeroStrengthTotal( caster ) * DAMAGE_PER_STRENGTH_POINT[abilityLevel], WEAPON_TYPE_METAL_HEAVY_BASH )
        endif
        set targetSelf = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set areaDamageAmount = AREA_DAMAGE[abilityLevel] + GetHeroIntelligenceTotal( caster ) * AREA_DAMAGE_PER_INTELLIGENCE_POINT[abilityLevel]
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call UnitDamageUnitBySpell( caster, GetUnit(enumUnit), areaDamageAmount )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes unit target returns string
        if ( IsUnitType( target, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_UNIT.self )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_DAMAGE[1] = 75
        set AREA_DAMAGE[2] = 75
        set AREA_DAMAGE_PER_INTELLIGENCE_POINT[1] = 2
        set AREA_DAMAGE_PER_INTELLIGENCE_POINT[2] = 2
        set AREA_RANGE[1] = 350
        set AREA_RANGE[2] = 350
        set DAMAGE[1] = 25
        set DAMAGE[2] = 50
        set DAMAGE_PER_STRENGTH_POINT[1] = 0
        set DAMAGE_PER_STRENGTH_POINT[2] = 0
        set DESTROYED_MANA[1] = 200
        set DESTROYED_MANA[2] = 330
        set DURATION[1] = 4
        set DURATION[2] = 5
        set DURATION_PER_MANA_POINT[1] = 0.04
        set DURATION_PER_MANA_POINT[2] = 0.04
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set HERO_DURATION[1] = 2
        set HERO_DURATION[2] = 2
        set HERO_DURATION_PER_MANA_POINT[1] = 0.01
        set HERO_DURATION_PER_MANA_POINT[2] = 0.01
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT2_PATH )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()