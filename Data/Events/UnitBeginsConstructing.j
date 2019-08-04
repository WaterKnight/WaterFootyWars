//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitBeginsConstructing
    globals
        private trigger DUMMY_TRIGGER
        private constant real START_LIFE_FACTOR = 0.15
    endglobals

    private function Trig takes nothing returns nothing
        local Unit constructingStructure = GetConstructingStructureEx()
        local player constructingStructureOwner = constructingStructure.owner
        local unit constructingStructureSelf = constructingStructure.self
        local UnitType constructingStructureType = constructingStructure.type
        call SetUnitState( constructingStructureSelf, UNIT_STATE_LIFE, (GetUnitTypeMaxLife( constructingStructureType ) + GetUnitTypeMaxLifeForPlayer( constructingStructureType, constructingStructureOwner )) * START_LIFE_FACTOR )
        set constructingStructureOwner = null
        set constructingStructureSelf = null
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
        loop
            call TriggerRegisterPlayerUnitEvent( DUMMY_TRIGGER, PlayerWJ( iteration ), EVENT_PLAYER_UNIT_CONSTRUCT_START, null )
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
    endfunction
endscope