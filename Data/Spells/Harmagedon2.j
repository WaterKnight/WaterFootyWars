//TESH.scrollpos=18
//TESH.alwaysfold=0
//! runtextmacro Scope("Harmagedon2")
    globals
        private constant integer ORDER_ID = 852093//OrderId( "massteleport" )
        public constant integer SPELL_ID = 'A04J'

        private constant real DELAY = 2.
        private constant real DURATION = 15.
        private constant real EFFECT_INTERVAL = 0.005
        private group ENUM_GROUP
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Human\\MarkOfChaos\\MarkOfChaosTarget.mdl"
        private rect TARGET_RECT
        private boolexpr TARGET_CONDITIONS

        private timer DURATION_TIMER
        private timer EFFECT_TIMER
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        return true
    endfunction

    private function Destroy takes nothing returns nothing
        local Unit enumUnit
        local unit enumUnitSelf
        local UnitType enumUnitType
        local integer iteration = GetTeams() - 1
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if ( enumUnitSelf != null ) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                set enumUnitType = enumUnit.type
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                if ( GetUnitRevaluation(enumUnit) == 2 ) then
                    call SetUnitRevaluation(enumUnit, 0)
                else
                    if ( (IsUnitTypeSpawn(enumUnitType) or (enumUnitType.id == RESERVE_UNIT_ID)) and ( IsUnitIllusionWJ( enumUnit ) == false ) ) then
                        call KillUnit( enumUnitSelf )
                    endif
                endif
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        call PauseTimer( EFFECT_TIMER )
        call SetCameraSourceNoise( GetLocalPlayer(), 0, 0 )
        call SetCameraTargetNoise( GetLocalPlayer(), 0, 0 )
        loop
            exitwhen ( iteration < 0 )
            call UnitAddAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
    endfunction

    private function CreateEffect takes nothing returns nothing
        call DestroyEffectTimed( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, GetRandomReal( GetRectMinX( TARGET_RECT ), GetRectMaxX( TARGET_RECT ) ), GetRandomReal( GetRectMinY( TARGET_RECT ), GetRectMaxY( TARGET_RECT ) ) ), 2 )
    endfunction

    private function PreDestroy takes nothing returns nothing
        call TimerStart( EFFECT_TIMER, EFFECT_INTERVAL, true, function CreateEffect )
        call TimerStart( DURATION_TIMER, DELAY, false, function Destroy )
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterTeam = GetPlayerTeam( caster.owner )
        local integer count = Infoboard_COUNT
        local integer iteration = GetTeams() - 1
        set DURATION_TIMER = CreateTimerWJ()
        loop
            exitwhen ( iteration < 0 )
            call UnitRemoveAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
        call DisplayTextTimedWJ( ColorStrings_RED + "Attention: Harmagedon " + ColorStrings_RESET + "(" + ColorStrings_GOLD + "team " + I2S( casterTeam + 1 ) + "|r)\nAll spawn units are going to be killed in " + I2S( R2I( DURATION ) ) + " seconds. In addition, the wimpy rest loses silver/gold state.\n(Start: " + GetTimeString( count ) + " End: " + GetTimeString( count + R2I( DURATION ) ) + ")" + ColorStrings_RESET, DURATION, GetLocalPlayer() )
        call PingMasterWizard( casterTeam )
        call PlaySoundFromType( HARMAGEDON_WARNING_SOUND_TYPE )
        call SetCameraSourceNoise( GetLocalPlayer(), 15, 11068 )
        call SetCameraTargetNoise( GetLocalPlayer(), 15, 11068 )
        call TimerStart( DURATION_TIMER, DURATION, false, function PreDestroy )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        set DURATION_TIMER = CreateTimerWJ()
        set EFFECT_TIMER = CreateTimerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        set TARGET_RECT = InitRect( gg_rct_Harmagedon2 )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()