//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitFinishesConstructing
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit constructedStructure returns nothing
        call Brick_ConstructingFinish( constructedStructure )
        call Grass_ConstructingFinish( constructedStructure )
        call Marble_ConstructingFinish( constructedStructure )
    endfunction

    private function Trig takes nothing returns nothing
        local Unit constructedStructure = GetUnit(GetConstructedStructure())

        call TriggerEvents_Static(constructedStructure)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope