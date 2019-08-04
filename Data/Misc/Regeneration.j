//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Regeneration")
    globals
        private group ENUM_GROUP
        private timer REFRESH_TIMER
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function TargetConditions takes nothing returns boolean
        if ( GetUnitState( GetFilterUnit(), UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        return true
    endfunction

    public function Refresh takes nothing returns nothing
        local Unit enumUnit
        local unit enumUnitSelf
        local real timeOut = TimerGetTimeout(REFRESH_TIMER)
        call GroupEnumUnitsInRectWJ( ENUM_GROUP, PLAY_RECT, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if (enumUnitSelf != null) then
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                call AddUnitState( enumUnitSelf, UNIT_STATE_LIFE, (GetUnitLifeRegeneration( enumUnit ) + GetUnitLifeRegenerationBonus( enumUnit )) * timeOut )
                call AddUnitState( enumUnitSelf, UNIT_STATE_MANA, (GetUnitManaRegeneration( enumUnit ) + GetUnitManaRegenerationBonus( enumUnit )) * timeOut )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnitSelf == null )
            endloop
        endif
        call TimerStart( REFRESH_TIMER, REGENERATION_INTERVAL * GetRandomReal(0.1, 0.3), false, function Refresh )
    endfunction

    public function Start takes nothing returns nothing
        call TimerStart( REFRESH_TIMER, REGENERATION_INTERVAL, false, function Refresh )
    endfunction

    public function Init takes nothing returns nothing
        set ENUM_GROUP = CreateGroupWJ()
        set REFRESH_TIMER = CreateTimerWJ()
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
    endfunction
//! runtextmacro Endscope()