//TESH.scrollpos=4
//TESH.alwaysfold=0
scope UnitBeginsCasting
    globals
        public trigger DUMMY_TRIGGER
    endglobals

    private function TriggerEvents_Static takes Unit caster, integer skill, real targetX, real targetY returns nothing
        call SilverSpores_BeginCast(caster)
        if ( skill == WonderSeeds_SPELL_ID ) then
            call WonderSeeds_BeginCast( caster, targetX, targetY )
        endif
    endfunction

    private function Trig takes nothing returns nothing
        local unit casterSelf = GetSpellAbilityUnit()
        local Unit caster = GetUnit(casterSelf)
        local integer casterOrderId = GetUnitCurrentOrder(casterSelf)
        local integer skill = GetSpellAbilityId()
        local location targetLocation = GetSpellTargetLoc()
        local Unit targetUnit = GetUnit(GetSpellTargetUnit())
        local real targetX
        local real targetY
        set casterSelf = null
        if ( targetLocation != null ) then
            set targetX = GetLocationX( targetLocation )
            set targetY = GetLocationY( targetLocation )
            call RemoveLocation( targetLocation )
            set targetLocation = null
        else
            set targetX = 0
            set targetY = 0
        endif

        if (UnitGetsOrder_TriggerEvents(GetAbilityOrderId(skill, casterOrderId), caster, caster.owner, targetX, targetY, skill, targetUnit, casterOrderId) == null) then
            call TriggerEvents_Static(caster, skill, targetX, targetY)
        else
            call StopUnit(caster)
        endif
    endfunction

    public function Init takes nothing returns nothing
        set DUMMY_TRIGGER = CreateTriggerWJ()
        call AddTriggerCode( DUMMY_TRIGGER, function Trig )
    endfunction
endscope