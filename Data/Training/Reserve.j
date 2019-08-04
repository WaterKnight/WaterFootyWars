//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Reserve")
    globals
        private constant integer AMOUNT = 3
    endglobals

    public function SellUnitExecute takes Unit reserve, UnitType reserveType returns nothing
        local integer iteration = 2
        local player owner = reserve.owner
        local unit reserveSelf = reserve.self
        local real angle = GetUnitFacingWJ(reserveSelf)
        local integer supplyUsed
        local real x = GetUnitX(reserveSelf)
        local real y = GetUnitY(reserveSelf)
        set reserveSelf = null
        set supplyUsed = GetUnitTypeSupplyUsed(reserveType) / AMOUNT
        loop
            call SetUnitSupplyUsed( reserve, owner, supplyUsed )
            exitwhen ( iteration > AMOUNT )
            set reserve = CreateUnitEx( owner, RESERVE_UNIT_ID, x, y, angle )
            set iteration = iteration + 1
        endloop
        set owner = null
    endfunction
//! runtextmacro Endscope()