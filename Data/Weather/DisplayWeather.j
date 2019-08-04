//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("DisplayWeather")
    public function Chat takes string chatMessage, player triggerPlayer returns nothing
        local boolean displaysWeatherEffects
        local integer iteration
        local weathereffect specificWeatherEffect
        local integer triggerPlayerId
        set chatMessage = StringCase( chatMessage, false )
        if ( chatMessage == "-w" ) then
            set triggerPlayerId = GetPlayerId(triggerPlayer)
            set displaysWeatherEffects = WeatherEffect_PLAYER_HIDES[triggerPlayerId]
            set iteration = WeatherEffect_COUNT
            set WeatherEffect_PLAYER_HIDES[triggerPlayerId] = ( displaysWeatherEffects == false )
            loop
                exitwhen ( iteration < 0 )
                set specificWeatherEffect = WeatherEffect_ALL[iteration]
                if ( WeatherEffect_IS_DISPLAYED[GetWeatherEffectIndex(specificWeatherEffect)] ) then
                    call EnableWeatherEffectWJ( specificWeatherEffect, triggerPlayer, displaysWeatherEffects )
                endif
                set iteration = iteration - 1
            endloop
            set specificWeatherEffect = null
        endif
    endfunction
//! runtextmacro Endscope()