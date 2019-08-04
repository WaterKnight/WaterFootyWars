//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitFinishesTraining
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit rax, Unit trainedUnit returns nothing
        local UnitType trainedUnitType = trainedUnit.type
        call Spawn_FinishTraining( rax, trainedUnit.self, trainedUnit.owner, trainedUnitType, trainedUnitType.id )
    endfunction

    private function Trig takes nothing returns nothing
        local Unit rax = GetUnit(GetTriggerUnit())
        local Unit trainedUnit = GetTrainedUnitEx()

        call TriggerEvents_Static(rax, trainedUnit)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope