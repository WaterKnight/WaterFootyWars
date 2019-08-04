//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("TownHall")
    globals
        private constant real BONUS_SCALE = 1.
        private constant real LENGTH = 250.
        private constant real SCALE_TIME = 1.
        private constant integer START_UNITS_AMOUNT = 5
        private constant real UPDATE_TIME = 0.035
        private constant real ANGLE_ADD = 30 * DEG_TO_RAD * UPDATE_TIME
    endglobals

    private struct Data
        real angle
        Unit researchCenter
        Unit townHall
        timer updateTimer
    endstruct

    private function GetTownHallData takes Unit townHall returns Data
        return GetAttachedIntegerById(townHall.id, TownHall_SCOPE_ID)
    endfunction

    public function Death takes Unit townHall, UnitType townHallType returns nothing
        if ( IsUnitTypeTownHall(townHallType) ) then
            call Miscellaneous_Spawn_Spawn_Destroy(townHall)
        endif
    endfunction

    private function Ending takes Data d, Unit townHall returns nothing
        call d.destroy()
        call FlushAttachedIntegerById(townHall.id, TownHall_SCOPE_ID)
        if (GetLocalPlayer() == townHall.owner) then
            call SetUnitScaleWJ(townHall.self, 0)
        endif
        //call AddUnitScaleTimedForPlayer( researchCenter, -BONUS_SCALE, SCALE_TIME, townHallOwner )
    endfunction

    //! runtextmacro Scope("Deselection")
        private struct Deselection_Data
            timer durationTimer
            Unit townHall
        endstruct

        private function Deselection_Ending takes Deselection_Data d, timer durationTimer, Unit townHall returns nothing
            call d.destroy()
            call FlushAttachedInteger(durationTimer, TownHall_SCOPE_ID)
            call DestroyTimerWJ(durationTimer)
            set durationTimer = null
            call FlushAttachedIntegerById(townHall.id, TownHall_SCOPE_ID)
            call BJDebugMsg("ende7")
            call Ending(GetTownHallData(townHall), townHall)
            call BJDebugMsg("ende8")
        endfunction

        private function Deselection_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Deselection_Data d = GetAttachedInteger(durationTimer, Deselection_SCOPE_ID)
            call Deselection_Ending(d, durationTimer, d.townHall)
            set durationTimer = null
            call BJDebugMsg("ende6")
        endfunction

        public function Deselection_EndingBySelect takes Unit townHall returns nothing
            local Deselection_Data d = GetAttachedIntegerById(townHall.id, Deselection_SCOPE_ID)
            if (d != NULL) then
                call Deselection_Ending(d, d.durationTimer, townHall)
            endif
        endfunction

        public function Deselection_Start takes Unit townHall returns nothing
            local Deselection_Data d = Deselection_Data.create()
            local timer durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.townHall = townHall
            call AttachInteger(durationTimer, Deselection_SCOPE_ID, d)
            call AttachIntegerById(townHall.id, Deselection_SCOPE_ID, d)
            call TimerStart(durationTimer, 0, false, function Deselection_EndingByTimer)
            set durationTimer = null
            call BJDebugMsg("ende5")
        endfunction
    //! runtextmacro Endscope()

    public function Deselect takes player townHallOwner, Unit triggerUnit returns nothing
        local Data d
        local Unit researchCenter = GetPlayerResearchCenter(townHallOwner)
        local Unit townHall
        call BJDebugMsg("ende1")
        if (researchCenter != NULL) then
        call BJDebugMsg("ende2")
            set townHall = GetPlayerTownHall(townHallOwner)
            call BJDebugMsg(B2S(IsUnitSelected(researchCenter.self, townHallOwner)))
            if (((triggerUnit == townHall) and (IsUnitSelected(researchCenter.self, townHallOwner) == false)) or ((triggerUnit == researchCenter) and (IsUnitSelected(townHall.self, townHallOwner) == false))) then
            call BJDebugMsg("ende3")
                set d = GetAttachedIntegerById(townHall.id, TownHall_SCOPE_ID)
                if (d != NULL) then
                call BJDebugMsg("ende4")
                    call Deselection_Deselection_Start(townHall)
                endif
            endif
        endif
    endfunction
    
    private function Update takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, TownHall_SCOPE_ID)
        local real angle = d.angle + ANGLE_ADD
        local unit researchCenter = d.researchCenter.self
        local unit townHall = d.townHall.self
        set updateTimer = null
        set d.angle = angle
        call BJDebugMsg("update")
        call SetUnitX(researchCenter, GetUnitX(townHall) + LENGTH * Cos(angle))
        call SetUnitY(researchCenter, GetUnitY(townHall) + LENGTH * Sin(angle))
        set researchCenter = null
        set townHall = null
    endfunction

    public function Select takes player townHallOwner, Unit triggerUnit returns nothing
        local integer townHallId
        local Data d
        local Unit researchCenter = GetPlayerResearchCenter(townHallOwner)
        local Unit townHall
        local timer updateTimer
        call BJDebugMsg("sel1")
        if (researchCenter != NULL) then
        call BJDebugMsg("sel2")
            set townHall = GetPlayerTownHall(townHallOwner)
            call BJDebugMsg(GetUnitName(researchCenter.self)+"; "+GetPlayerName(townHallOwner))
            if ((triggerUnit == townHall) or (triggerUnit == researchCenter)) then
            call BJDebugMsg("sel3")
                set townHallId = townHall.id
                set d = GetAttachedIntegerById(townHallId, TownHall_SCOPE_ID)
                call Deselection_Deselection_EndingBySelect(townHall)
                if (d == NULL) then
                call BJDebugMsg("sel4")
                    set d = Data.create()
                    set researchCenter = GetPlayerResearchCenter(townHall.owner)
                    set updateTimer = CreateTimerWJ()
                    set d.angle = GetRandomReal(0, 2 * PI)
                    set d.researchCenter = researchCenter
                    set d.townHall = townHall
                    set d.updateTimer = updateTimer
                    call AttachIntegerById(townHallId, TownHall_SCOPE_ID, d)
                    call AttachInteger(updateTimer, TownHall_SCOPE_ID, d)
                    if (GetLocalPlayer() == townHallOwner) then
                        call SetUnitScaleWJ(townHall.self, GetUnitTypeScale(townHall.type))
                    endif
                    //call AddUnitScaleTimedForPlayer( researchCenter, BONUS_SCALE, SCALE_TIME, townHallOwner )
                    call TimerStart(updateTimer, UPDATE_TIME, true, function Update)
                    set updateTimer = null
                endif
            endif
        endif
    endfunction

    public function UpgradeFinish takes Unit townHall, player townHallOwner, UnitType townHallType returns nothing
        local integer iteration
        local real newUnitX
        local real newUnitY
        local real townHallX
        local real townHallY
        local integer spawnTypeId
        local Race specificRace
        local real townHallCenterAngle
        local Race townHallRace
        local unit townHallSelf
        if ( IsUnitTypeTownHall(townHallType) ) then
            set townHallRace = GetUnitTypeRace(townHallType)
            set townHallSelf = townHall.self
            set townHallX = GetUnitX( townHallSelf )
            set townHallY = GetUnitY( townHallSelf )
            if ( IsPlayerStarted(townHallOwner) == false ) then
                set townHallCenterAngle = Atan2( CENTER_Y - townHallY, CENTER_X - townHallX )
                set iteration = 1
                set newUnitX = townHallX + 300 * Cos( townHallCenterAngle )
                set newUnitY = townHallY + 300 * Sin( townHallCenterAngle )
                set spawnTypeId = GetUnitTypeSpawnTypeId(townHallType)
                if ( GetPlayerController( townHallOwner ) == MAP_CONTROL_COMPUTER ) then
                    call IssuePointOrderById( townHallSelf, SET_RALLY_ORDER_ID, 0, 0 )
                endif
                call SetPlayerStarted(townHallOwner, true)
                call CreateAltar( townHallOwner )
                loop
                    call CreateUnitEx(townHallOwner, spawnTypeId, newUnitX, newUnitY, townHallCenterAngle)
                    set iteration = iteration + 1
                    exitwhen (iteration > START_UNITS_AMOUNT)
                endloop
            endif
            if (GetUnitTypeSpawnStage(townHallType) == 0) then
                set TEMP_UNIT = CreateUnitEx(townHallOwner, GetRaceResearchCenter(townHallRace), townHallX, townHallY, STANDARD_ANGLE)
                call SetPlayerResearchCenter( townHallOwner, TEMP_UNIT )
            endif
            call UnitAddAbility( townHallSelf, DELIVER_LUMBER_SPELL_ID )
            if (GetPlayerTechCount(townHallOwner, FeelingOfSecurity_RESEARCH_ID, true) > 0) then
                call UnitAddAbility( townHallSelf, FeelingOfSecurity_UPGRADED_SPELL_ID )
            else
                call UnitAddAbility( townHallSelf, FeelingOfSecurity_SPELL_ID )
            endif
            set townHallSelf = null
            call SetPlayerRaceWJ(townHallOwner, townHallRace)
            call Miscellaneous_Spawn_Spawn_Start( townHall, GetUnitTypeSpawnTypeId(townHallType), townHallOwner )
        endif
    endfunction
//! runtextmacro Endscope()