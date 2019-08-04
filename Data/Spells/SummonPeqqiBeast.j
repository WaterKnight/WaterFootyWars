//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("SummonPeqqiBeast")
    globals
        private constant integer ORDER_ID = 852596//OrderId( "summonwareagle" )
        public constant integer SPELL_ID = 'A03P'

        private constant real DURATION = 30.
        private constant real OFFSET = 100.
        private constant real RELEASE_TIME = 1.034
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl"
        private constant integer SUMMONS_AMOUNT = 2
    endglobals

    private struct Data
        Unit array beasts[SUMMONS_AMOUNT]
        timer releaseTimer
    endstruct

    private function Release takes nothing returns nothing
        local Unit beast
        local Unit array beasts
        local unit beastSelf
        local integer count = SUMMONS_AMOUNT - 1
        local integer iteration = count
        local timer releaseTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(releaseTimer, SummonPeqqiBeast_SCOPE_ID)
        loop
            set beasts[iteration] = d.beasts[iteration]
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        set iteration = count
        call d.destroy()
        call FlushAttachedInteger(releaseTimer, SummonPeqqiBeast_SCOPE_ID)
        call DestroyTimerWJ( releaseTimer )
        set releaseTimer = null
        loop
            set beast = beasts[iteration]
            set beastSelf = beast.self
            call PauseUnit( beastSelf, false )
            call SetUnitInvulnerable( beastSelf, false )
            call SetUnitBlendTime( beastSelf, 0.15 )
            call UnitApplyTimedLifeWJ( beastSelf, DURATION )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set beastSelf = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local Unit beast
        local unit beastSelf
        local player casterOwner = caster.owner
        local unit casterSelf = caster.self
        local real casterAngle = GetUnitFacingWJ( casterSelf )
        local real casterX = GetUnitX( casterSelf ) + OFFSET * Cos(casterAngle)
        local real casterY = GetUnitY( casterSelf ) + OFFSET * Sin(casterAngle)
        local Data d = Data.create()
        local integer iteration = SUMMONS_AMOUNT - 1
        local timer releaseTimer = CreateTimerWJ()
        set casterSelf = null
        set d.releaseTimer = releaseTimer
        call AttachInteger(releaseTimer, SummonPeqqiBeast_SCOPE_ID, d)
        loop
            set beast = CreateUnitEx( casterOwner, PEQQI_BEAST_UNIT_ID, casterX, casterY, casterAngle )
            set beastSelf = beast.self
            call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, GetUnitX( beastSelf ), GetUnitY( beastSelf ) ) )
            set d.beasts[iteration] = beast
            call SetUnitBlendTime( beastSelf, 0 )
            call SetUnitAnimation( beastSelf, "birth" )
            call PauseUnit( beastSelf, true )
            call SetUnitInvulnerable( beastSelf, true )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set beastSelf = null
        set casterOwner = null
        call TimerStart( releaseTimer, RELEASE_TIME, false, function Release )
        set releaseTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()