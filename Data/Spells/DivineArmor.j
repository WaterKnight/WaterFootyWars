//TESH.scrollpos=66
//TESH.alwaysfold=0
//! runtextmacro Scope("DivineArmor")
    globals
        public constant integer SPELL_ID = 'A041'

        private constant integer DUMMY_UNIT_ID = 'h00F'
        private real array CHANCE
        private real array DURATION
        private real array HERO_DURATION
    endglobals

    private function Damage_Conditions takes player casterOwner, unit target returns boolean
        if ( IsUnitAlly( target, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_MELEE_ATTACKER ) == false ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX
        local real casterY
        local unit dummyUnit
        local real duration
        local unit targetSelf
        if (abilityLevel > 0) then
            set targetSelf = target.self
            if ( Damage_Conditions( caster.owner, targetSelf ) ) then
                if ( GetRandomReal( 0.01, 1 ) < CHANCE[abilityLevel] ) then
                    set casterX = GetUnitX( casterSelf )
                    set casterY = GetUnitY( casterSelf )
                    set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, casterX, casterY, GetUnitFacingWJ( casterSelf ) + PI )
                    call SetUnitAnimationByIndex( dummyUnit, 1 )
                    call RemoveUnitTimed( dummyUnit, 2 )
                    set dummyUnit = null
                    if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                        set duration = HERO_DURATION[abilityLevel]
                    else
                        set duration = DURATION[abilityLevel]
                    endif
                    call SetUnitStunTimed( target, 1, duration )
                endif
            endif
            set targetSelf = null
        endif
        set casterSelf = null
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( TRIGGER_UNIT, DAMAGE_SOURCE )
    endfunction

    public function Learn takes Unit caster returns nothing
        //! runtextmacro AddEventById( "caster.id", "EVENT_DAMAGE" )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set CHANCE[1] = 0.25
        set CHANCE[2] = 0.25
        set CHANCE[3] = 0.28
        set CHANCE[4] = 0.30
        set CHANCE[5] = 0.32
        set DURATION[1] = 1.8
        set DURATION[2] = 2
        set DURATION[3] = 2.2
        set DURATION[4] = 2.4
        set DURATION[5] = 2.6
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY", "0", "function Damage_Event" )
        set HERO_DURATION[1] = 1
        set HERO_DURATION[2] = 1.3
        set HERO_DURATION[3] = 1.6
        set HERO_DURATION[4] = 1.9
        set HERO_DURATION[5] = 2.2
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
    endfunction
//! runtextmacro Endscope()