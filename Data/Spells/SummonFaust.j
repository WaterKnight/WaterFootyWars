//TESH.scrollpos=135
//TESH.alwaysfold=0
//! runtextmacro Scope("SummonFaust")
    globals
        private constant integer ATTACK_GRAPHIC_SPELL_ID = 'A00R'
        private constant integer FAUST_ID = 'n00N'
        private constant integer ORDER_ID = 852594//OrderId( "summongrizzly" )
        public constant integer SPELL_ID = 'A02H'

        private constant real AREA_RANGE = 800.
        private constant real BONUS_HEAL_BY_SPELL = -0.5
        private constant real DURATION = 60.
        private constant real RELEASE_TIME = 1.5
        private timer RELEASE_TIMER
        private constant string SPECIAL_EFFECT_PATH = "Objects\\Spawnmodels\\Other\\ToonBoom\\ToonBoom.mdl"
        private constant real UPDATE_TIME = 0.035
        private constant real ANGLE_ADD = 600 * DEG_TO_RAD * UPDATE_TIME / RELEASE_TIME
        private timer UPDATE_TIMER

        private real FACING
        private Unit FAUST = NULL
        private effect SPECIAL_EFFECT
    endglobals

    //! runtextmacro Scope("AttackGraphic")
        globals
            public constant integer AttackGraphic_SPELL_ID = 'A00R'

            private constant string AttackGraphic_CASTER_EFFECT_PATH = "Abilities\\Weapons\\AvengerMissile\\AvengerMissile.mdl"
            private constant string AttackGraphic_CASTER_EFFECT_ATTACHMENT_POINT = "weapon"
            private constant string AttackGraphic_TARGET_EFFECT_PATH = "Abilities\\Weapons\\Catapult\\CatapultMissile.mdl"
            private constant string AttackGraphic_TARGET_EFFECT_ATTACHMENT_POINT = "origin"

            private effect AttackGraphic_CASTER_EFFECT
        endglobals

        public function AttackGraphic_Death takes Unit caster returns nothing
            local integer casterId
            if ( caster.type.id == FAUST_UNIT_ID ) then
                set casterId = caster.id
                //! runtextmacro RemoveEventById( "casterId", "AttackGraphic_EVENT_DAMAGE" )
                //! runtextmacro RemoveEventById( "casterId", "AttackGraphic_EVENT_DEATH" )
                call DestroyEffectWJ(AttackGraphic_CASTER_EFFECT)
            endif
        endfunction

        private function AttackGraphic_Death_Event takes nothing returns nothing
            call AttackGraphic_Death( DYING_UNIT )
        endfunction

        public function AttackGraphic_Damage takes unit caster, unit target returns nothing
            if ( GetUnitAbilityLevel( caster, SPELL_ID ) > 0 ) then
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( AttackGraphic_TARGET_EFFECT_PATH, target, AttackGraphic_TARGET_EFFECT_PATH ) )
            endif
        endfunction

        private function AttackGraphic_Damage_Event takes nothing returns nothing
            call AttackGraphic_Damage( DAMAGE_SOURCE.self, TRIGGER_UNIT.self )
        endfunction

        public function AttackGraphic_Learn takes Unit caster returns nothing
            local integer casterId = caster.id
            //! runtextmacro AddEventById( "casterId", "AttackGraphic_EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "casterId", "AttackGraphic_EVENT_DEATH" )
            set AttackGraphic_CASTER_EFFECT = AddSpecialEffectTargetWJ( AttackGraphic_CASTER_EFFECT_PATH, caster.self, AttackGraphic_CASTER_EFFECT_ATTACHMENT_POINT )
        endfunction

        private function AttackGraphic_Learn_Event takes nothing returns nothing
            call AttackGraphic_Learn(LEARNER)
        endfunction

        public function AttackGraphic_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "AttackGraphic_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_AS_DAMAGE_SOURCE", "0", "function AttackGraphic_Damage_Event" )
            //! runtextmacro CreateEvent( "AttackGraphic_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function AttackGraphic_Death_Event" )
            call InitEffectType( AttackGraphic_CASTER_EFFECT_PATH )
            call InitEffectType( AttackGraphic_TARGET_EFFECT_PATH )
            //! runtextmacro AddNewEventById( "AttackGraphic_EVENT_LEARN", "AttackGraphic_SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function AttackGraphic_Learn_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Death takes Unit faust returns nothing
        local integer iteration
        if ( faust.type.id == FAUST_UNIT_ID ) then
            set iteration = GetTeams() - 1
            //! runtextmacro RemoveEventById( "FAUST.id", "EVENT_DEATH" )
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
        local unit faustSelf = FAUST.self
        call DestroyEffectWJ(SPECIAL_EFFECT)
        call PauseTimer( RELEASE_TIMER )
        call PauseTimer( UPDATE_TIMER )
        call SetUnitInvulnerable( faustSelf, false )
        call PauseUnit( faustSelf, false )
        call UnitApplyTimedLifeWJ( faustSelf, DURATION )
        set faustSelf = null
    endfunction

    private function Turn takes nothing returns nothing
        set FACING = FACING + ANGLE_ADD
        call SetUnitFacingWJ( FAUST.self, FACING )
    endfunction

    public function SpellEffect takes player casterOwner returns nothing
        local real angle = GetRandomReal( 0, PI * 2 )
        local integer casterTeam = GetPlayerTeam( casterOwner )
        local unit faustSelf
        local integer iteration = GetTeams() - 1
        local real length = GetRandomReal( 0, AREA_RANGE )
        local real x = length * Cos( angle )
        local real y = length * Sin( angle )
        set FACING = GetRandomReal( 0, 2 * PI )
        set FAUST = CreateUnitEx( casterOwner, FAUST_UNIT_ID, x, y, FACING )
        set faustSelf = FAUST.self
        loop
            exitwhen ( iteration < 0 )
            call UnitRemoveAbility( MASTER_WIZARDS[iteration].self, SPELL_ID )
            set iteration = iteration - 1
        endloop
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, x, y ) )
        set SPECIAL_EFFECT = AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, x, y )
        //! runtextmacro AddEventById( "FAUST.id", "EVENT_DEATH" )
        call AddUnitHealBySpell( FAUST, BONUS_HEAL_BY_SPELL )
        call SetUnitInvulnerable( faustSelf, true )
        call PauseUnit( faustSelf, true )
        set faustSelf = null
        call AddUnitScaleTimed( FAUST, 1.75, RELEASE_TIME )
        call DisplayTextTimedWJ( ColorStrings_RED + "Attention: Faust has entered this world - your world. In his terrifying state of frenzy, he massacres everyone fatuous enough stepping into his battle range.|r", 10, GetLocalPlayer() )
        call PingMasterWizard( casterTeam )
        call PlaySoundFromType( FAUST_LAUGH_SOUND_TYPE )
        call TimerStart( UPDATE_TIMER, UPDATE_TIME, true, function Turn )
        call TimerStart( RELEASE_TIMER, RELEASE_TIME, false, function Release )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER.owner )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set RELEASE_TIMER = CreateTimerWJ()
        set UPDATE_TIMER = CreateTimerWJ()
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call AttackGraphic_AttackGraphic_Init()
    endfunction
//! runtextmacro Endscope()