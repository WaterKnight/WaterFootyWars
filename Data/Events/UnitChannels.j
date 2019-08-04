//TESH.scrollpos=0
//TESH.alwaysfold=0
scope UnitChannels
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit caster, integer skill, Unit targetUnit returns nothing
        if ( skill == MindBreaker_SPELL_ID ) then
            call MindBreaker_Channel( caster, targetUnit )
        elseif (skill == TownPortal_SPELL_ID) then
            call TownPortal_Channel(caster)
        endif
    endfunction

    private function Trig takes nothing returns nothing
        local Unit caster = GetUnit(GetSpellAbilityUnit())
        local integer skill = GetSpellAbilityId()
        local Unit targetUnit = GetUnit(GetSpellTargetUnit())
        local location targetLocation = GetSpellTargetLoc()
        local real targetX
        local real targetY
        if ( targetLocation != null ) then
            set targetX = GetLocationX( targetLocation )
            set targetY = GetLocationY( targetLocation )
            call RemoveLocationWJ( targetLocation )
            set targetLocation = null
        else
            set targetX = 0
            set targetY = 0
        endif

        call TriggerEvents_Static(caster, skill, targetUnit)
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope