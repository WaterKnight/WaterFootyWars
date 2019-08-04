//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitTakesAnyDamage
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents takes real damageAmount, Unit damageSource, Unit triggerUnit returns nothing
        set damageAmount = Lens_Target_Target_AnyDamage(damageAmount, damageSource, triggerUnit)

        set DAMAGE_AMOUNT = damageAmount
    endfunction

    private function Trig takes nothing returns nothing
        local real damageAmount = DAMAGE_AMOUNT
        local Unit damageSource = DAMAGE_SOURCE
        local Unit triggerUnit = TRIGGER_UNIT

        call TriggerEvents(damageAmount, damageSource, triggerUnit)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope