//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Creeps")
    globals
        private constant string RESPAWN_EFFECT_PATH = "Abilities\\Spells\\Human\\Resurrect\\ResurrectTarget.mdl"
        private constant string RESPAWN_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    //! runtextmacro Scope("Market")
        globals
            private group Market_CREEP_GROUP
            private integer array Market_CREEP_UNIT_IDS
            private integer Market_CREEP_UNIT_IDS_COUNT = -1
            private constant integer Market_CREEPS_AMOUNT = 2
            private constant real Market_RESPAWN_TIME = 30.
        endglobals

        private struct Market_Data
            group creepGroup
            timer respawnTimer
            rect targetRect
        endstruct

        //! runtextmacro Scope("Release")
            globals
                private constant real Release_DURATION = 1.
            endglobals

            private struct Release_Data
                Unit creep
            endstruct

            private function Release_Ending takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Release_Data d = GetAttachedInteger(durationTimer, Release_SCOPE_ID)
                local Unit creep = d.creep
                call FlushAttachedInteger(durationTimer, Release_SCOPE_ID)
                call DestroyTimerWJ(durationTimer)
                set durationTimer = null
                call RemoveUnitAttackSilence(creep)
                call RemoveUnitInvulnerability(creep)
            endfunction

            public function Release_Start takes Unit creep returns nothing
                local Release_Data d = Release_Data.create()
                local timer durationTimer = CreateTimerWJ()
                set d.creep = creep
                call AttachInteger(durationTimer, Release_SCOPE_ID, d)
                call AddUnitAttackSilence(creep)
                call AddUnitInvulnerability(creep)
                call TimerStart(durationTimer, Release_DURATION, false, function Release_Ending)
                set durationTimer = null
            endfunction
        //! runtextmacro Endscope()

        public function Market_StartCreeps takes group creepGroup, Market_Data d, rect targetRect returns nothing
            local real angle
            local Unit creep
            local integer creepId
            local unit creepSelf
            local integer iteration = Market_CREEPS_AMOUNT
            loop
                set angle = GetRandomReal(0, 2 * PI)
                set creep = CreateUnitEx(NEUTRAL_AGGRESSIVE_PLAYER, Market_CREEP_UNIT_IDS[GetRandomInt(0, Market_CREEP_UNIT_IDS_COUNT)], GetRandomReal(GetRectMinX(targetRect), GetRectMaxX(targetRect)), GetRandomReal(GetRectMinY(targetRect), GetRectMaxY(targetRect)), angle)
                set creepId = creep.id
                set creepSelf = creep.self
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( RESPAWN_EFFECT_PATH, creepSelf, RESPAWN_EFFECT_ATTACHMENT_POINT ) )
                call AttachIntegerById(creepId, Market_SCOPE_ID, d)
                //! runtextmacro AddEventById( "creepId", "Market_EVENT_DEATH" )
                call GroupAddUnit(creepGroup, creepSelf)
                call Release_Release_Start(creep)
                set iteration = iteration - 1
                exitwhen (iteration < 1)
            endloop
            set creepSelf = null
        endfunction

        private function Market_Respawn takes nothing returns nothing
            local timer respawnTimer = GetExpiredTimer()
            local Market_Data d = GetAttachedInteger(respawnTimer, Market_SCOPE_ID)
            set respawnTimer = null
            call Market_StartCreeps(d.creepGroup, d, d.targetRect)
        endfunction

        public function Market_Death takes Unit creep returns nothing
            local group creepGroup
            local integer creepId = creep.id
            local Market_Data d = GetAttachedIntegerById(creepId, Market_SCOPE_ID)
            if ( d != NULL ) then
                set creepGroup = d.creepGroup
                call FlushAttachedIntegerById(creepId, Market_SCOPE_ID)
                //! runtextmacro RemoveEventById( "creepId", "Market_EVENT_DEATH" )
                call GroupRemoveUnit(creepGroup, creep.self)
                if (FirstOfGroup(creepGroup) == null) then
                    call TimerStart(d.respawnTimer, Market_RESPAWN_TIME, false, function Market_Respawn)
                endif
                set creepGroup = null
            endif
        endfunction

        private function Market_Death_Event takes nothing returns nothing
            call Market_Death( DYING_UNIT )
        endfunction

        public function Market_Start takes integer period returns nothing
            local group creepGroup = CreateGroupWJ()
            local Market_Data d = Market_Data.create()
            local timer respawnTimer = CreateTimerWJ()
            //! runtextmacro RotateRectAroundCenter("CREEPS_MARKET_RECT", "PI")
            set d.creepGroup = creepGroup
            set d.respawnTimer = respawnTimer
            set d.targetRect = dummyRect
            call AttachInteger(respawnTimer, Market_SCOPE_ID, d)
            set respawnTimer = null
            call Market_StartCreeps(creepGroup, d, dummyRect)
            set creepGroup = null
            set dummyRect = null
        endfunction

        private function Market_AddCreepUnitTypeId takes integer whichUnitTypeId returns nothing
            set Market_CREEP_UNIT_IDS_COUNT = Market_CREEP_UNIT_IDS_COUNT + 1
            set Market_CREEP_UNIT_IDS[Market_CREEP_UNIT_IDS_COUNT] = whichUnitTypeId
        endfunction

        public function Market_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Market_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Market_Death_Event" )
            call Market_AddCreepUnitTypeId(MURLOC_NIGHTSTALKER_UNIT_ID)
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("MercenaryCamp")
        globals
            private group MercenaryCamp_CREEP_GROUP
            private integer array MercenaryCamp_CREEP_UNIT_IDS
            private integer MercenaryCamp_CREEP_UNIT_IDS_COUNT = -1
            private constant integer MercenaryCamp_CREEPS_AMOUNT = 1
            private constant real MercenaryCamp_RESPAWN_TIME = 30.
        endglobals

        private struct MercenaryCamp_Data
            group creepGroup
            timer respawnTimer
            rect targetRect
        endstruct

        //! runtextmacro Scope("Release")
            globals
                private constant real Release_DURATION = 1.
            endglobals

            private struct Release_Data
                Unit creep
            endstruct

            private function Release_Ending takes nothing returns nothing
                local timer durationTimer = GetExpiredTimer()
                local Release_Data d = GetAttachedInteger(durationTimer, Release_SCOPE_ID)
                local Unit creep = d.creep
                call FlushAttachedInteger(durationTimer, Release_SCOPE_ID)
                call DestroyTimerWJ(durationTimer)
                set durationTimer = null
                call RemoveUnitAttackSilence(creep)
                call RemoveUnitInvulnerability(creep)
            endfunction

            public function Release_Start takes Unit creep returns nothing
                local Release_Data d = Release_Data.create()
                local timer durationTimer = CreateTimerWJ()
                set d.creep = creep
                call AttachInteger(durationTimer, Release_SCOPE_ID, d)
                call AddUnitAttackSilence(creep)
                call AddUnitInvulnerability(creep)
                call TimerStart(durationTimer, Release_DURATION, false, function Release_Ending)
                set durationTimer = null
            endfunction
        //! runtextmacro Endscope()

        public function MercenaryCamp_StartCreeps takes group creepGroup, MercenaryCamp_Data d, rect targetRect returns nothing
            local real angle
            local Unit creep
            local integer creepId
            local unit creepSelf
            local integer iteration = MercenaryCamp_CREEPS_AMOUNT
            loop
                set angle = GetRandomReal(0, 2 * PI)
                set creep = CreateUnitEx(NEUTRAL_AGGRESSIVE_PLAYER, MercenaryCamp_CREEP_UNIT_IDS[GetRandomInt(0, MercenaryCamp_CREEP_UNIT_IDS_COUNT)], GetRandomReal(GetRectMinX(targetRect), GetRectMaxX(targetRect)), GetRandomReal(GetRectMinY(targetRect), GetRectMaxY(targetRect)), angle)
                set creepId = creep.id
                set creepSelf = creep.self
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( RESPAWN_EFFECT_PATH, creepSelf, RESPAWN_EFFECT_ATTACHMENT_POINT ) )
                call AttachIntegerById(creepId, MercenaryCamp_SCOPE_ID, d)
                //! runtextmacro AddEventById( "creepId", "MercenaryCamp_EVENT_DEATH" )
                call GroupAddUnit(creepGroup, creepSelf)
                call Release_Release_Start(creep)
                set iteration = iteration - 1
                exitwhen (iteration < 1)
            endloop
            set creepSelf = null
        endfunction

        private function MercenaryCamp_Respawn takes nothing returns nothing
            local timer respawnTimer = GetExpiredTimer()
            local MercenaryCamp_Data d = GetAttachedInteger(respawnTimer, MercenaryCamp_SCOPE_ID)
            set respawnTimer = null
            call MercenaryCamp_StartCreeps(d.creepGroup, d, d.targetRect)
        endfunction

        public function MercenaryCamp_Death takes Unit creep returns nothing
            local group creepGroup
            local integer creepId = creep.id
            local MercenaryCamp_Data d = GetAttachedIntegerById(creepId, MercenaryCamp_SCOPE_ID)
            if ( d != NULL ) then
                set creepGroup = d.creepGroup
                call FlushAttachedIntegerById(creepId, MercenaryCamp_SCOPE_ID)
                //! runtextmacro RemoveEventById( "creepId", "MercenaryCamp_EVENT_DEATH" )
                call GroupRemoveUnit(creepGroup, creep.self)
                if (FirstOfGroup(creepGroup) == null) then
                    call TimerStart(d.respawnTimer, MercenaryCamp_RESPAWN_TIME, false, function MercenaryCamp_Respawn)
                endif
                set creepGroup = null
            endif
        endfunction

        private function MercenaryCamp_Death_Event takes nothing returns nothing
            call MercenaryCamp_Death( DYING_UNIT )
        endfunction

        public function MercenaryCamp_Start takes integer period returns nothing
            local group creepGroup = CreateGroupWJ()
            local MercenaryCamp_Data d = MercenaryCamp_Data.create()
            local timer respawnTimer = CreateTimerWJ()
            //! runtextmacro RotateRectAroundCenter("CREEPS_MERCENARY_CAMP_RECT", "PI")
            set d.creepGroup = creepGroup
            set d.respawnTimer = respawnTimer
            set d.targetRect = dummyRect
            call AttachInteger(respawnTimer, MercenaryCamp_SCOPE_ID, d)
            set respawnTimer = null
            call MercenaryCamp_StartCreeps(creepGroup, d, dummyRect)
            set creepGroup = null
            set dummyRect = null
        endfunction

        private function MercenaryCamp_AddCreepUnitTypeId takes integer whichUnitTypeId returns nothing
            set MercenaryCamp_CREEP_UNIT_IDS_COUNT = MercenaryCamp_CREEP_UNIT_IDS_COUNT + 1
            set MercenaryCamp_CREEP_UNIT_IDS[MercenaryCamp_CREEP_UNIT_IDS_COUNT] = whichUnitTypeId
        endfunction

        public function MercenaryCamp_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "MercenaryCamp_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function MercenaryCamp_Death_Event" )
            call MercenaryCamp_AddCreepUnitTypeId(SEA_GIANT_UNIT_ID)
        endfunction
    //! runtextmacro Endscope()

    public function Start takes nothing returns nothing
        local integer iteration = 1
        loop
            call Market_Market_Start(iteration)
            call MercenaryCamp_MercenaryCamp_Start(iteration)
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
    endfunction

    public function Init takes nothing returns nothing
        call Market_Market_Init()
        call MercenaryCamp_MercenaryCamp_Init()
    endfunction
//! runtextmacro Endscope()