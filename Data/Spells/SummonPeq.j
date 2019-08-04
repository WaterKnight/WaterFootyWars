//TESH.scrollpos=72
//TESH.alwaysfold=0
//! runtextmacro Scope("SummonPeq")
    globals
        private constant integer ORDER_ID = 852595//OrderId( "summonquillbeast" )
        public constant integer SPELL_ID = 'A038'

        private constant real AREA_RANGE = 800.
        private constant real BONUS_HEAL_BY_SPELL = -0.5
        private constant real DURATION = 80.
        private constant real RELEASE_TIME = 1.5
        private timer RELEASE_TIMER
        private constant string SPECIAL_EFFECT_PATH = "Objects\\Spawnmodels\\Other\\ToonBoom\\ToonBoom.mdl"
        private constant real UPDATE_TIME = 0.035
        private timer UPDATE_TIMER
        private constant real ANGLE_ADD = 600 * DEG_TO_RAD * UPDATE_TIME / RELEASE_TIME

        private real FACING
        private Unit PEQ = NULL
    endglobals

    public function Death takes Unit peq returns nothing
        local integer iteration
        if ( peq == PEQ ) then
            set iteration = GetTeams() - 1
            //! runtextmacro RemoveEventById( "PEQ.id", "EVENT_DEATH" )
            loop
                exitwhen ( iteration < 0 )
                call UnitAddAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
                set iteration = iteration - 1
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function Release takes nothing returns nothing
        local unit peqSelf = PEQ.self
        call PauseTimer( UPDATE_TIMER )
        //! runtextmacro AddEventById( "PEQ.id", "EVENT_DEATH" )
        call SetUnitInvulnerable( peqSelf, false )
        call PauseUnit( peqSelf, false )
        call UnitApplyTimedLifeWJ( peqSelf, DURATION )
        set peqSelf = null
    endfunction

    private function Turn takes nothing returns nothing
        set FACING = FACING + ANGLE_ADD
        call SetUnitFacingWJ( PEQ.self, FACING )
    endfunction

    public function SpellEffect takes player casterOwner returns nothing
        local real angle = GetRandomReal( 0, PI * 2 )
        local integer casterTeam = GetPlayerTeam( casterOwner )
        local integer iteration = GetTeams() - 1
        local real length = GetRandomReal( 0, AREA_RANGE )
        local unit peqSelf
        local real x = length * Cos( angle )
        local real y = length * Sin( angle )
        set FACING = GetRandomReal( 0, 2 * PI )
        set PEQ = CreateUnitEx( casterOwner, PEQ_UNIT_ID, x, y, FACING )
        set peqSelf = PEQ.self
        loop
            exitwhen ( iteration < 0 )
            call UnitRemoveAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, x, y ) )
        call AddUnitHealBySpell( PEQ, BONUS_HEAL_BY_SPELL )
        call SetUnitInvulnerable( peqSelf, true )
        call PauseUnit( peqSelf, true )
        set peqSelf = null
        call AddUnitScaleTimed( PEQ, 1.75, RELEASE_TIME )
        call DisplayTextTimedWJ( ColorStrings_RED + "Attention please: Peq the Sorcerer was summoned and strives for the mortals' lives.|r", 10, GetLocalPlayer() )
        call PingMasterWizard( casterTeam )
        call PlaySoundFromType( PEQ_WARCRY_SOUND_TYPE )
        call TimerStart( UPDATE_TIMER, UPDATE_TIME, true, function Turn )
        call TimerStart( RELEASE_TIMER, RELEASE_TIME, false, function Release )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER.owner )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set RELEASE_TIMER = CreateTimer()
        set UPDATE_TIMER = CreateTimer()
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()