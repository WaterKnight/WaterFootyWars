//TESH.scrollpos=15
//TESH.alwaysfold=0
//! runtextmacro Scope("Harmagedon")
    globals
        private constant integer ORDER_ID = 852093//OrderId( "massteleport" )
        public constant integer SPELL_ID = 'A035'

        private real array DESTINATION_X
        private real array DESTINATION_Y
        private constant real DURATION = 10.
        private timer DURATION_TIMER
        private group ENUM_GROUP
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\MassTeleport\\MassTeleportTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"

        private integer CASTER_TEAM
    endglobals

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
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

    private function MoveUnits takes nothing returns nothing
        local unit enumUnit
        local real targetX = DESTINATION_X[CASTER_TEAM]
        local real targetY = DESTINATION_Y[CASTER_TEAM]
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call SetUnitPosition( enumUnit, targetX, targetY )
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnit, TARGET_EFFECT_ATTACHMENT_POINT ) )
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        set CASTER_TEAM = GetPlayerTeam( caster.owner )
        call DisplayTextTimedWJ( ColorStrings_RED + "Attention: Harmagedon\nAll units are going to be teleported in the base of " + ColorStrings_GOLD + "team " + I2S( CASTER_TEAM + 1 ) + ColorStrings_RESET + " after " + I2S( R2I( DURATION ) ) + " seconds have elapsed." + ColorStrings_RESET, 10, GetLocalPlayer() )
        call PingMasterWizard( CASTER_TEAM )
        call PlaySoundFromType( HARMAGEDON_WARNING_SOUND_TYPE )
        call TimerStart( DURATION_TIMER, DURATION, false, function MoveUnits )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local real differenceX = GetRectCenterX( gg_rct_Harmagedon ) - CENTER_X
        local real differenceY = GetRectCenterY( gg_rct_Harmagedon ) - CENTER_Y
        local real angle = Atan2( differenceY, differenceX )
        local real difference = SquareRoot( differenceX * differenceX + differenceY * differenceY )
        local integer iteration = GetTeams() - 1
        local integer teamsAmount = GetTeams()
        local real angleAdd = 2 * PI / teamsAmount
        set DURATION_TIMER = CreateTimerWJ()
        set ENUM_GROUP = CreateGroupWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        loop
            set angle = angle + angleAdd
            set DESTINATION_X[iteration] = CENTER_X + difference * Cos( angle )
            set DESTINATION_Y[iteration] = CENTER_Y + difference * Sin( angle )
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()