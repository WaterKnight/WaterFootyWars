//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("ReleaseUnitShredder")
    globals
        private constant real DURATION = 180.
        private constant real RELEASE_TIME = 1.634
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Orc\\FeralSpirit\\feralspirittarget.mdl"
    endglobals

    private struct Data
        Unit shredder
    endstruct

    private function Release takes nothing returns nothing
        local timer releaseTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(releaseTimer, ReleaseUnitShredder_SCOPE_ID)
        local Unit shredder = d.shredder
        local unit shredderSelf = shredder.self
        call d.destroy()
        call FlushAttachedInteger( releaseTimer, ReleaseUnitShredder_SCOPE_ID )
        call DestroyTimerWJ( releaseTimer )
        set releaseTimer = null
        call PauseUnit( shredderSelf, false )
        call SetUnitInvulnerable( shredderSelf, false )
        call SetUnitBlendTime( shredderSelf, 0.15 )
        call SetUnitAnimationByIndex( shredderSelf, 0 )
        call UnitApplyTimedLifeWJ( shredderSelf, DURATION )
        set shredderSelf = null
    endfunction

    public function Attack takes Unit shredder, Unit triggerUnit returns nothing
        if ( ( shredder.type == GetUnitType(UNIT_SHREDDER_UNIT_ID) ) and ( IsUnitAlly( triggerUnit.self, shredder.owner ) == false ) ) then
            call StopUnit( shredder )
        endif
    endfunction

    public function SellUnitExecute takes player owner, Unit shop, unit shredderSelf returns nothing
        local Data d = Data.create()
        local timer releaseTimer = CreateTimerWJ()
        local unit shopSelf = shop.self
        local real angle = GetUnitFacingWJ( shopSelf )
        local Unit shredder
        local real x = GetUnitX( shopSelf )
        local real y = GetUnitY( shopSelf )
        set shopSelf = null
        call RemoveUnitEx( shop )
        set SHREDDERS[GetPlayerTeam(owner)] = NULL
        call RemoveUnitWJ( shredderSelf )
        set shredder = CreateUnitEx( owner, UNIT_SHREDDER_RELEASED_UNIT_ID, x, y, PI / 2 + B2I( Absolute( 1.5 - GetPlayerTeam( owner ) ) > 1 ) * PI )
        set owner = null
        set shredderSelf = shredder.self
        set d.shredder = shredder
        call SetUnitX( shredderSelf, x )
        call SetUnitY( shredderSelf, y )
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, x, y ) )
        call SetUnitBlendTime( shredderSelf, 0 )
        call SetUnitAnimationByIndex( shredderSelf, 3 )
        call PauseUnit( shredderSelf, true )
        call SetUnitInvulnerable( shredderSelf, true )
        set shredderSelf = null
        call AttachInteger( releaseTimer, ReleaseUnitShredder_SCOPE_ID, d )
        call TimerStart( releaseTimer, RELEASE_TIME, false, function Release )
        set releaseTimer = null
    endfunction

    public function Init takes nothing returns nothing
        call InitEffectType( SPECIAL_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()