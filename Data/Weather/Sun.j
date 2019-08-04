//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Sun")
    globals
        private weathereffect EFFECT_WEATHER_EFFECT
        private constant real EFFECT_WEATHER_EFFECT_FADE_OUT = 3
        private constant integer EFFECT_WEATHER_EFFECT_PATH = 'LRaa'
    endglobals

    public function Ending takes nothing returns nothing
        call EnableWeatherEffectTimed( EFFECT_WEATHER_EFFECT, null, false, EFFECT_WEATHER_EFFECT_FADE_OUT )
    endfunction

    public function Start takes nothing returns nothing
        call DisplayTextTimedWJ( "Sun", 15, GetLocalPlayer() )
        call EnableWeatherEffectWJ( EFFECT_WEATHER_EFFECT, null, true )
    endfunction

    public function Init takes nothing returns nothing
        set EFFECT_WEATHER_EFFECT = AddWeatherEffectWJ( PLAY_RECT, EFFECT_WEATHER_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()