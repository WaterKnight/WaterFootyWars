//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("WeatherEffect")
    globals
        public weathereffect array ALL
        public integer COUNT = -1
        public boolean array IS_DISPLAYED
        public boolean array PLAYER_HIDES
        weathereffect TEMP_WEATHER_EFFECT
    endglobals

    function GetWeatherEffectIndex takes weathereffect whichWeatherEffect returns integer
        return (GetHandleId(whichWeatherEffect) * ( -1 ) - 101)
    endfunction

    function AddWeatherEffectWJ takes rect whichRect, integer whichWeatherType returns weathereffect
        local weathereffect newWeatherEffect = AddWeatherEffect( whichRect, whichWeatherType )
        local integer index = GetWeatherEffectIndex(newWeatherEffect)
        set COUNT = COUNT + 1
        set ALL[COUNT] = newWeatherEffect
        set IS_DISPLAYED[index] = false
        call AddObject( newWeatherEffect, "WeatherEffect" )
        ///call AddSavedIntegerToTable( "Objects", "WeatherEffects", newWeatherEffectId )
        set TEMP_WEATHER_EFFECT = newWeatherEffect
        set newWeatherEffect = null
        return TEMP_WEATHER_EFFECT
    endfunction

    function EnableWeatherEffectWJ takes weathereffect whichWeatherEffect, player whichPlayer, boolean flag returns nothing
        if ( whichPlayer == null ) then
            set IS_DISPLAYED[GetWeatherEffectIndex(whichWeatherEffect)] = flag
            set whichPlayer = GetLocalPlayer()
        endif
        if ( GetLocalPlayer() == whichPlayer ) then
            if ( flag ) then
                if ( PLAYER_HIDES[GetPlayerId(whichPlayer)] == false ) then
                    call EnableWeatherEffect( whichWeatherEffect, flag )
                endif
            else
                call EnableWeatherEffect( whichWeatherEffect, flag )
            endif
        endif
    endfunction

    function RemoveWeatherEffectWJ takes weathereffect whichWeatherEffect returns nothing
        local integer iteration = COUNT
        loop
            exitwhen (ALL[iteration] == whichWeatherEffect)
            set iteration = iteration - 1
        endloop
        set ALL[iteration] = ALL[COUNT]
        set COUNT = COUNT - 1
        call RemoveObject( whichWeatherEffect, "WeatherEffect" )
        ///call RemoveSavedIntegerFromTable( "Objects", "WeatherEffects", newWeatherEffectId )
        if ( whichWeatherEffect == null ) then
            call WriteBug( "Fatal: RemoveWeatherEffectWJ" )
        else
            call RemoveWeatherEffect( whichWeatherEffect )
            set whichWeatherEffect = null
        endif
    endfunction

    //! runtextmacro Scope("EnableTimed")
        private struct EnableTimed_Data
            boolean flag
            weathereffect target
            player whichPlayer
        endstruct

        private function EnableTimed_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local EnableTimed_Data d = GetAttachedInteger( durationTimer, EnableTimed_SCOPE_ID )
            local boolean flag = d.flag
            local weathereffect target = d.target
            local player whichPlayer = d.whichPlayer
            call d.destroy()
            call FlushAttachedInteger( durationTimer, EnableTimed_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            call EnableWeatherEffectWJ( target, whichPlayer, flag )
            set target = null
            set whichPlayer = null
        endfunction

        function EnableWeatherEffectTimed takes weathereffect target, player whichPlayer, boolean flag, real time returns nothing
            local EnableTimed_Data d = EnableTimed_Data.create()
            local timer durationTimer = CreateTimerWJ()
            set d.flag = flag
            set d.target = target
            set d.whichPlayer = whichPlayer
            call AttachInteger( durationTimer, EnableTimed_SCOPE_ID, d )
            call TimerStart( durationTimer, time, false, function EnableTimed_Ending )
            set durationTimer = null
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("RemoveTimed")
        private struct RemoveTimed_Data
            weathereffect target
        endstruct

        private function RemoveTimed_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local RemoveTimed_Data d = GetAttachedInteger( durationTimer, RemoveTimed_SCOPE_ID )
            local weathereffect target = d.target
            call d.destroy()
            call FlushAttachedInteger( durationTimer, RemoveTimed_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            call RemoveWeatherEffectWJ( target )
            set target = null
        endfunction

        function RemoveWeatherEffectTimed takes weathereffect target, real time returns nothing
            local RemoveTimed_Data d = RemoveTimed_Data.create()
            local timer durationTimer = CreateTimerWJ()
            set d.target = target
            call AttachInteger( durationTimer, RemoveTimed_SCOPE_ID, d )
            call TimerStart( durationTimer, time, false, function RemoveTimed_Ending )
            set durationTimer = null
        endfunction
    //! runtextmacro Endscope()
//! runtextmacro Endscope()