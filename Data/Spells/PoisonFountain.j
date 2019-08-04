//TESH.scrollpos=114
//TESH.alwaysfold=0
//! runtextmacro Scope("PoisonFountain")
    globals
        private constant integer ORDER_ID = 852202//OrderId( "restoration" )
        private constant integer POISONED_FOUNTAIN_ID = 'n00O'
        public constant integer SPELL_ID = 'A02G'

        private constant real AREA_RANGE = 550
        private constant real DURATION = 30
        private group ENUM_GROUP
        private constant string FOUNTAIN_EFFECT_PATH = "Abilities\\Spells\\Undead\\Unsummon\\UnsummonTarget.mdl"
        private constant string FOUNTAIN_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real INTERVAL = 0.5
        private constant real DAMAGE_PER_INTERVAL = 20 * INTERVAL
        private constant integer POISON_EFFECT_CIRCLES_AMOUNT = 3
        private constant string POISON_EFFECT_PATH = "Abilities\\Spells\\Other\\Drain\\DrainCaster.mdl"
        private constant integer POISON_EFFECT_AMOUNT_PER_CIRCLE = 3
        private boolexpr TARGET_CONDITIONS

        private timer DURATION_TIMER
        private sound EFFECT_SOUND
        private effect FOUNTAIN_EFFECT
        private timer INTERVAL_TIMER
    endglobals

    private function Ending takes nothing returns nothing
        local integer iteration = GetTeams() - 1
        call DestroyTimerWJ( DURATION_TIMER )
        call StopSound( EFFECT_SOUND, true, false )
        call DestroyEffectWJ( FOUNTAIN_EFFECT )
        call DestroyTimerWJ( INTERVAL_TIMER )
        call RemoveUnitEx( FOUNTAIN )
        set FOUNTAIN = CreateUnitEx( NEUTRAL_PASSIVE_PLAYER, FOUNTAIN_UNIT_ID, 0, 0, STANDARD_ANGLE )
        loop
            exitwhen ( iteration < 0 )
            call UnitAddAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( FILTER_UNIT == FOUNTAIN ) then
            return false
        endif
        set TEMP_PLAYER = FILTER_UNIT.owner
        if ( GetPlayerId( TEMP_PLAYER ) == PLAYER_NEUTRAL_PASSIVE ) then
            return false
        endif
        if ( GetPlayerId( TEMP_PLAYER ) == PLAYER_NEUTRAL_AGGRESSIVE ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        return true
    endfunction

    private function DealDamage takes nothing returns nothing
        local real angle
        local unit enumUnit
        local real angleDifference = 2 * PI / POISON_EFFECT_AMOUNT_PER_CIRCLE
        local integer iteration = 1
        local integer iteration2
        local real length
        local real lengthDifference = AREA_RANGE / POISON_EFFECT_CIRCLES_AMOUNT
        loop
            exitwhen ( iteration > POISON_EFFECT_CIRCLES_AMOUNT )
            set iteration2 = 1
            loop
                exitwhen ( iteration2 > POISON_EFFECT_AMOUNT_PER_CIRCLE )
                set angle = GetRandomReal( 0, 2 * PI )
                set length = iteration * lengthDifference
                call DestroyEffectTimed( AddSpecialEffectWJ( POISON_EFFECT_PATH, length * Cos( angle ), length * Sin( angle ) ), 1 )
                set iteration2 = iteration2 + 1
            endloop
            set iteration = iteration + 1
        endloop
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, 0, 0, AREA_RANGE, TARGET_CONDITIONS )
        loop
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            exitwhen ( enumUnit == null )
            call GroupRemoveUnit( ENUM_GROUP, enumUnit )
            call UnitDamageUnitBySpell( FOUNTAIN, GetUnit(enumUnit), DAMAGE_PER_INTERVAL )
        endloop
    endfunction

    public function SpellEffect takes player casterOwner returns nothing
        local integer casterTeam = GetPlayerTeam( casterOwner )
        local integer count = Infoboard_COUNT
        local unit fountainSelf
        local integer iteration = GetTeams() - 1
        call RemoveUnitEx( FOUNTAIN )
        set DURATION_TIMER = CreateTimerWJ()
        set EFFECT_SOUND = CreateSoundFromType( POISON_FOUNTAIN_LOOP_SOUND_TYPE )
        set FOUNTAIN = CreateUnitEx( casterOwner, POISONED_FOUNTAIN_UNIT_ID, 0, 0, STANDARD_ANGLE )
        set fountainSelf = FOUNTAIN.self
        set FOUNTAIN_EFFECT = AddSpecialEffectTargetWJ( FOUNTAIN_EFFECT_PATH, FOUNTAIN.self, FOUNTAIN_EFFECT_ATTACHMENT_POINT )
        set INTERVAL_TIMER = CreateTimerWJ()
        loop
            exitwhen ( iteration < 0 )
            call UnitRemoveAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
        call DisplayTextTimedWJ( "|cffff0000Attention: |cffffcc00Team " + I2S( casterTeam + 1 ) + "|r has poisoned the central fountain. It is advised to stay away from it until the poison soup has dispersed.\n(Start: " + GetTimeString( count ) + " End: " + GetTimeString( count + R2I( DURATION ) ) + ")|r", 10, GetLocalPlayer() )
        call PingMasterWizard( casterTeam )
        call AttachSoundToUnit( EFFECT_SOUND, fountainSelf )
        set fountainSelf = null
        call StartSound( EFFECT_SOUND )
        call TimerStart( INTERVAL_TIMER, INTERVAL, true, function DealDamage )
        call TimerStart( DURATION_TIMER, DURATION, false, function Ending )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER.owner )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( FOUNTAIN_EFFECT_PATH )
        call InitEffectType( POISON_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()