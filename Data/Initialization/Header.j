ESH.scrollpos=0
//TESH.alwaysfold=0
scope Header
    public function Init takes nothing returns nothing
        call BoolExpr_Init()
        call Dialog_Init()
        call Effect_Init()
        call Group_Init()
        call Location_Init()
        call Miscellaneous_Init()
        call Player_Init()
        call Trigger_Init()
        call Lightning_Init()
        call Unit_Init()
    endfunction
endscope