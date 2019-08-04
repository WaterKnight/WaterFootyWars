//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("TimeOfDay")
    globals
        private constant integer DAWN_EFFECT_WEATHER_EFFECT_TYPE_ID = 'LRma'
        private constant integer DUSK_EFFECT_WEATHER_EFFECT_TYPE_ID = 'LRaa'
        private weathereffect EFFECT_WEATHER_EFFECT
    endglobals

    public function Dusk takes nothing returns nothing
        call RemoveWeatherEffectWJ( EFFECT_WEATHER_EFFECT )
        set EFFECT_WEATHER_EFFECT = AddWeatherEffectWJ( PLAY_RECT, DUSK_EFFECT_WEATHER_EFFECT_TYPE_ID )
        call EnableWeatherEffectWJ( EFFECT_WEATHER_EFFECT, null, true )
    endfunction

    public function Dawn takes nothing returns nothing
        call RemoveWeatherEffectWJ( EFFECT_WEATHER_EFFECT )
        set EFFECT_WEATHER_EFFECT = AddWeatherEffectWJ( PLAY_RECT, DAWN_EFFECT_WEATHER_EFFECT_TYPE_ID )
        call EnableWeatherEffectWJ( EFFECT_WEATHER_EFFECT, null, true )
    endfunction

    public function Start takes nothing returns nothing
        local integer newWeatherEffectTypeId
        if (dawn) then
            set newWeatherEffectTypeId = DAWN_EFFECT_WEATHER_EFFECT_TYPE_ID
        else
            set newWeatherEffectTypeId = DUSK_EFFECT_WEATHER_EFFECT_TYPE_ID
        endif
        set EFFECT_WEATHER_EFFECT = AddWeatherEffectWJ( PLAY_RECT, newWeatherEffectTypeId )
    endfunction
//! runtextmacro Endscope()