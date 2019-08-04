//TESH.scrollpos=0
//TESH.alwaysfold=0
scope DestructableDies
    globals
        private trigger DUMMY_TRIGGER
    endglobals

    private function Trig takes nothing returns nothing
        local destructable triggerDestructable = GetDyingDestructable()

        call DestructableRestoreLife( triggerDestructable, GetDestructableMaxLife( triggerDestructable ), true )

        set triggerDestructable = null
    endfunction

    public function RegisterDestructable takes destructable whichDestructable returns nothing
        call TriggerRegisterDeathEvent( DUMMY_TRIGGER, whichDestructable )
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope