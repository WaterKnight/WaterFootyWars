//TESH.scrollpos=0
//TESH.alwaysfold=0
scope LightningDies
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes lightning triggerLightning returns nothing
        call Lightning_AddLightningBetweenUnits_AddLightningBetweenUnits_EffectLightning_Death( triggerLightning )
        call Snow_Ghost_EffectLightning_EffectLightning_EffectLightning_Death( triggerLightning )
    endfunction

    private function Trig takes nothing returns nothing
        local lightning triggerLightning = TRIGGER_LIGHTNING

        call TriggerEvents_Static(triggerLightning)

        call DestroyLightningWJ( triggerLightning )

        set triggerLightning = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope