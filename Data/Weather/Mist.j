//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Mist")
    globals
        private SoundType array EFFECT_SOUND_TYPES
        private timer INTERVAL_TIMER
        private constant real MAX_INTERVAL = 10.
        private constant real MIN_INTERVAL = 8.
        private constant real SOUND_MAX_INTERVAL = 9.
        private constant real SOUND_MIN_INTERVAL = 6.
        private timer SOUND_TIMER
    endglobals

    //! runtextmacro Scope("Cloud")
        private struct Cloud_Data
            unit dummyUnit
            timer durationTimer
            rect targetRect
        endstruct

        globals
            private trigger Cloud_DUMMY_TRIGGER
            private constant integer Cloud_DUMMY_UNIT_ID = 'n00F'
            private constant real Cloud_MAX_DURATION = 20.
            private constant real Cloud_MIN_DURATION = 16.
            private group Cloud_ENUM_GROUP
            private constant real Cloud_SIZE = 320.
            private boolexpr Cloud_TARGET_CONDITIONS
            private group Cloud_TARGET_GROUP
            private region Cloud_TARGET_REGION

            private Cloud_Data array DS
            private integer DS_AMOUNT
        endglobals

        private function Cloud_TargetConditions_Single takes unit checkingUnit, boolean isBoarding returns boolean
            if ( IsUnitInGroup( checkingUnit, Cloud_TARGET_GROUP ) == isBoarding ) then
                return false
            endif
            if ( IsUnitType( checkingUnit, UNIT_TYPE_FLYING ) ) then
                return false
            endif
            return true
        endfunction

        private function Cloud_TargetConditions takes nothing returns boolean
            if ( Cloud_TargetConditions_Single( GetFilterUnit(), true ) == false ) then
                return false
            endif
            return true
        endfunction

        private function Cloud_EndTarget takes Unit target returns nothing
            local unit targetSelf = target.self
            if ( Cloud_TargetConditions_Single( targetSelf, false ) ) then
                call GroupRemoveUnit( Cloud_TARGET_GROUP, targetSelf )
                call AddUnitEvasionChance( target, -0.2 )
            endif
            set targetSelf = null
        endfunction

        private function Cloud_StartTarget takes Unit target returns nothing
            local unit targetSelf = target.self
            if ( Cloud_TargetConditions_Single( targetSelf, true ) ) then
                call GroupAddUnit( Cloud_TARGET_GROUP, targetSelf )
                call AddUnitEvasionChance( target, 0.2 )
            endif
            set targetSelf = null
        endfunction

        private function Cloud_Trig_UnitEntersOrLeaves takes nothing returns nothing
            local Unit triggerUnit = GetUnit(GetTriggerUnit())
            if ( GetHandleId(GetTriggerEventId()) == 5 ) then
                call Cloud_StartTarget( triggerUnit )
            else
                call Cloud_EndTarget( triggerUnit )
            endif
        endfunction

        private function Cloud_Ending takes Cloud_Data d, timer durationTimer returns nothing
            local unit dummyUnit = d.dummyUnit
            local unit enumUnit
            local integer iteration
            local rect targetRect = d.targetRect
            local rect targetRect2
            call d.destroy()
            call SetUnitAnimationByIndex( dummyUnit, 2 )
            call RemoveUnitTimed( dummyUnit, 0.5 )
            set dummyUnit = null
            call FlushAttachedInteger( durationTimer, Cloud_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set DS_AMOUNT = DS_AMOUNT - 1
            set iteration = DS_AMOUNT
            loop
                exitwhen (DS[iteration] == d)
                set iteration = iteration - 1
            endloop
            set DS[iteration] = DS[DS_AMOUNT]
            set iteration = DS_AMOUNT
            call RegionClearRect( Cloud_TARGET_REGION, PLAY_RECT )
            loop
                exitwhen ( iteration < 0 )
                set d = DS[iteration]
                set targetRect2 = d.targetRect
                call RegionAddRect( Cloud_TARGET_REGION, targetRect2 )
                set iteration = iteration + 1
            endloop
            set targetRect2 = null
            call GroupEnumUnitsInRectWJ( Cloud_ENUM_GROUP, targetRect, Cloud_TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup( Cloud_ENUM_GROUP )
            if (enumUnit != null) then
                loop
                    call GroupRemoveUnit( Cloud_ENUM_GROUP, enumUnit )
                    if ( IsUnitInRegion( Cloud_TARGET_REGION, enumUnit ) == false ) then
                        call Cloud_EndTarget( GetUnit(enumUnit) )
                    endif
                    set enumUnit = FirstOfGroup( Cloud_ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
            call RemoveRectWJ( targetRect )
            set targetRect = null
        endfunction

        public function Cloud_EndingByEnding takes nothing returns nothing
            local Cloud_Data d
            local integer iteration = DS_AMOUNT - 1
            loop
                exitwhen ( iteration < 0 )
                set d = DS[iteration]
                call Cloud_Ending( d, d.durationTimer )
                set iteration = iteration - 1
            endloop
        endfunction

        private function Cloud_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Cloud_Data d = GetAttachedInteger(durationTimer, Cloud_SCOPE_ID)
            call Cloud_Ending( d, durationTimer )
            set durationTimer = null
        endfunction

        public function Cloud_Start takes nothing returns nothing
            local Cloud_Data d = Cloud_Data.create()
            local timer durationTimer = CreateTimerWJ()
            local unit enumUnit
            local real x = GetRandomReal( PLAY_RECT_MIN_X, PLAY_RECT_MAX_X )
            local real y = GetRandomReal( PLAY_RECT_MIN_Y, PLAY_RECT_MAX_Y )
            local rect targetRect = CreateRectWithSize( x, y, Cloud_SIZE, Cloud_SIZE )
            set d.dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Cloud_DUMMY_UNIT_ID, x, y, STANDARD_ANGLE )
            set d.targetRect = targetRect
            call AttachInteger( durationTimer, Cloud_SCOPE_ID, d )
            call AttachInteger( durationTimer, Cloud_SCOPE_ID, d )
            set DS[DS_AMOUNT] = d
            set DS_AMOUNT = DS_AMOUNT + 1
            call RegionAddRect( Cloud_TARGET_REGION, targetRect )
            call GroupEnumUnitsInRectWJ( Cloud_ENUM_GROUP, targetRect, Cloud_TARGET_CONDITIONS )
            set targetRect = null
            set enumUnit = FirstOfGroup(Cloud_ENUM_GROUP)
            if (enumUnit != null) then
                loop
                    call GroupRemoveUnit( Cloud_ENUM_GROUP, enumUnit )
                    call Cloud_StartTarget( GetUnit(enumUnit) )
                    set enumUnit = FirstOfGroup( Cloud_ENUM_GROUP )
                    exitwhen ( enumUnit == null )
                endloop
            endif
            call TimerStart( durationTimer, GetRandomReal( Cloud_MIN_DURATION, Cloud_MAX_DURATION ), false, function Cloud_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Cloud_Init takes nothing returns nothing
            set Cloud_DUMMY_TRIGGER = CreateTriggerWJ()
            set Cloud_ENUM_GROUP = CreateGroupWJ()
            set Cloud_TARGET_CONDITIONS = ConditionWJ(function Cloud_TargetConditions)
            set Cloud_TARGET_GROUP = CreateGroupWJ()
            set Cloud_TARGET_REGION = CreateRegionWJ()
            call InitUnitType( Cloud_DUMMY_UNIT_ID )
            call AddTriggerCode( Cloud_DUMMY_TRIGGER, function Cloud_Trig_UnitEntersOrLeaves )
            call TriggerRegisterEnterRegion( Cloud_DUMMY_TRIGGER, Cloud_TARGET_REGION, null )
            call TriggerRegisterLeaveRegion( Cloud_DUMMY_TRIGGER, Cloud_TARGET_REGION, null )
        endfunction
    //! runtextmacro Endscope()

    public function Ending takes nothing returns nothing
    return
        call Cloud_Cloud_EndingByEnding()
    endfunction

    private function EffectSound takes nothing returns nothing
        local sound effectSound
        set effectSound = CreateSoundFromType( EFFECT_SOUND_TYPES[GetRandomInt(1, 7)] )
        call StartSound( effectSound )
        call StopSound(effectSound, true, true)
        set effectSound = null
        call TimerStart( SOUND_TIMER, GetRandomReal( SOUND_MIN_INTERVAL, SOUND_MAX_INTERVAL ), false, function EffectSound )
    endfunction

    private function Interval takes nothing returns nothing
        call Cloud_Cloud_Start()
        call TimerStart( INTERVAL_TIMER, GetRandomReal( MIN_INTERVAL, MAX_INTERVAL), false, function Interval )
    endfunction

    public function Start takes nothing returns nothing
        call DisplayTextTimedWJ( "Mist", 15, GetLocalPlayer() )
        return
        call TimerStart( INTERVAL_TIMER, GetRandomReal( MIN_INTERVAL, MAX_INTERVAL ), false, function Interval )
        call TimerStart( SOUND_TIMER, GetRandomReal( SOUND_MIN_INTERVAL, SOUND_MAX_INTERVAL ), false, function EffectSound )
    endfunction

    public function Init takes nothing returns nothing
        set EFFECT_SOUND_TYPES[1] = MIST_SOUND_TYPE
        set EFFECT_SOUND_TYPES[2] = MIST2_SOUND_TYPE
        set EFFECT_SOUND_TYPES[3] = MIST3_SOUND_TYPE
        set EFFECT_SOUND_TYPES[4] = MIST4_SOUND_TYPE
        set EFFECT_SOUND_TYPES[5] = MIST5_SOUND_TYPE
        set EFFECT_SOUND_TYPES[6] = MIST6_SOUND_TYPE
        set EFFECT_SOUND_TYPES[7] = MIST7_SOUND_TYPE
        set INTERVAL_TIMER = CreateTimerWJ()
        set SOUND_TIMER = CreateTimerWJ()
        call Cloud_Cloud_Init()
    endfunction
//! runtextmacro Endscope()