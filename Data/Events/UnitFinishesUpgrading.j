//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitFinishesUpgrading
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit triggerUnit, player triggerUnitOwner, UnitType triggerUnitType, real triggerUnitX, real triggerUnitY returns nothing
        call Miscellaneous_Altar_Altar_UpgradeFinish( triggerUnit, triggerUnitOwner, triggerUnitType, triggerUnitX, triggerUnitY )
        call TownHall_UpgradeFinish( triggerUnit, triggerUnitOwner, triggerUnitType )
    endfunction

    private function Trig takes nothing returns nothing
        local unit triggerUnitSelf = GetTriggerUnit()
        local Unit triggerUnit = GetUnit(triggerUnitSelf)
        local real triggerUnitMaxLife = GetUnitState( triggerUnitSelf, UNIT_STATE_MAX_LIFE )
        local boolean resetLife = ( triggerUnitMaxLife != 0 )
        local real triggerUnitLifeRelative
        local player triggerUnitOwner = triggerUnit.owner
        local UnitType triggerUnitType = GetUnitType(GetUnitTypeId(triggerUnitSelf))
        local real triggerUnitX = GetUnitX( triggerUnitSelf )
        local real triggerUnitY = GetUnitY( triggerUnitSelf )
        if ( resetLife ) then
            set triggerUnitLifeRelative = GetUnitState( triggerUnitSelf, UNIT_STATE_LIFE ) / triggerUnitMaxLife
        endif
        call Upgrade_Remove( triggerUnit )
        call UnitChangesForm_Start(triggerUnit, triggerUnitType, triggerUnit.type)

        call TriggerEvents_Static(triggerUnit, triggerUnitOwner, triggerUnitType, triggerUnitX, triggerUnitY)

        if ( resetLife ) then
            call SetUnitState( triggerUnitSelf, UNIT_STATE_LIFE, triggerUnitLifeRelative * GetUnitState( triggerUnitSelf, UNIT_STATE_MAX_LIFE ) )
        endif
        set triggerUnitOwner = null
        set triggerUnitSelf = null
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope