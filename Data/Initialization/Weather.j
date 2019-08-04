//TESH.scrollpos=0
//TESH.alwaysfold=0
scope Weather
    public function Init takes nothing returns nothing
        call Mist_Init()
        call Rain_Init()
        call Snow_Init()
        call Sun_Init()
    endfunction
endscope