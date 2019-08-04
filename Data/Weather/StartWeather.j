//TESH.scrollpos=18
//TESH.alwaysfold=0
//! runtextmacro Scope("StartWeather")
    globals
        private constant real INTERVAL = 30.
        private timer INTERVAL_TIMER
        private integer LAST_WEATHER
    endglobals

    private function StartNew takes integer whichWeather returns nothing
        set LAST_WEATHER = whichWeather
        if ( whichWeather == 0 ) then
            call Sun_Start()
        elseif ( whichWeather == 1 ) then
            call Rain_Start()
        elseif ( whichWeather == 2 ) then
            call Snow_Start()
        elseif ( whichWeather == 3 ) then
            call Mist_Start()
        endif
    endfunction

    private function Interval takes nothing returns nothing
        local integer newWeather = ModulateInt( LAST_WEATHER + 1, 4 )
        if ( LAST_WEATHER == 0 ) then
            call Sun_Ending()
        elseif ( LAST_WEATHER == 1 ) then
            call Rain_Ending()
        elseif ( LAST_WEATHER == 2 ) then
            call Snow_Ending()
        elseif ( LAST_WEATHER == 3 ) then
            call Mist_Ending()
        endif
        call StartNew( newWeather )
    endfunction

    public function Start takes nothing returns nothing
        set INTERVAL_TIMER = CreateTimerWJ()
        call StartNew( 2 )
        call TimerStart( INTERVAL_TIMER, INTERVAL, true, function Interval )
    endfunction
//! runtextmacro Endscope()