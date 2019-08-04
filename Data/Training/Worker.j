//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Worker")
    globals
        private constant integer MAX_UNITS_AMOUNT = 5
        private integer array WORKERS_AMOUNT
    endglobals

    public function Death takes player workerOwner, UnitType workerType returns nothing
        local integer ownerId
        if ( workerType.id == WORKER_UNIT_ID ) then
            set ownerId = GetPlayerId(workerOwner)
            set WORKERS_AMOUNT[ownerId] = WORKERS_AMOUNT[ownerId] - 1
        endif
    endfunction

    private function Add takes Unit worker, player workerOwner returns nothing
        local integer ownerId = GetPlayerId(workerOwner)
        local integer amount = WORKERS_AMOUNT[ownerId] + 1
        set WORKERS_AMOUNT[ownerId] = amount
        call IssueImmediateOrderById( worker.self, HARVESTING_AUTO_ORDER_ID )
    endfunction

    public function Appearance takes Unit worker, player workerOwner, UnitType workerType returns nothing
        if ( workerType.id == WORKER_UNIT_ID ) then
            call Add(worker, workerOwner)
        endif
    endfunction

    public function SellUnit takes player workerOwner returns string
        local integer ownerId = GetPlayerId(workerOwner)
        if ( WORKERS_AMOUNT[ownerId] + 1 > MAX_UNITS_AMOUNT ) then
            return "You can only train up to " + I2S( MAX_UNITS_AMOUNT ) + " workers"
        endif
        return null
    endfunction
//! runtextmacro Endscope()