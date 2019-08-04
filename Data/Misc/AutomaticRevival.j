//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("AutomaticRevival")
    globals
        constant integer REVIVE_ORDER_ID = 852027
    endglobals

    private struct Data
        Unit hero
    endstruct

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, AutomaticRevival_SCOPE_ID)
        local Unit hero = d.hero
        local Unit townHall = GetPlayerTownHall(hero.owner)
        call d.destroy()
        call FlushAttachedInteger( durationTimer, AutomaticRevival_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null

        if (townHall != NULL) then
            call IssueTargetOrderById(townHall.self, REVIVE_ORDER_ID, hero.self)
        endif
    endfunction

    public function Revivable takes Unit hero returns nothing
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        set d.hero = hero
        call AttachInteger(durationTimer, AutomaticRevival_SCOPE_ID, d)
        call TimerStart( durationTimer, 0, false, function Ending )
        set durationTimer = null
    endfunction
//! runtextmacro Endscope()