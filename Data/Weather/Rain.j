//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Rain")
    globals
        private sound EFFECT_SOUND
        private weathereffect EFFECT_WEATHER_EFFECT
        private constant real EFFECT_WEATHER_EFFECT_FADE_OUT = 3
        private constant integer EFFECT_WEATHER_EFFECT_PATH = 'RLlr'
        private timer INTERVAL_TIMER
        private constant real MAX_INTERVAL = 15.
        private constant real MIN_INTERVAL = 5.
    endglobals

    //! runtextmacro Scope("Cloud")
        private struct Cloud_Data
            timer dropTimer
            unit dummyUnit
            timer durationTimer
            real lengthX
            real lengthY
            timer lightningTimer
            timer moveTimer
            real x
            real y
        endstruct

        globals
            private constant integer Cloud_DUMMY_UNIT_ID = 'n00E'
            private constant real Cloud_DROP_AREA_RANGE = 800.
            private constant real Cloud_DROP_DURATION = 2.
            private constant string Cloud_DROP_EFFECT_PATH = "Abilities\\Spells\\Human\\SpellSteal\\SpellStealTarget.mdl"
            private constant real Cloud_DROP_INTERVAL = 0.5
            private constant real Cloud_MAX_LIGHTNING_INTERVAL = 8.
            private constant real Cloud_MIN_LIGHTNING_INTERVAL = 0.5
            private constant real Cloud_SIZE = 300.
            private constant real Cloud_SPEED = 200.
            private constant real Cloud_UPDATE_TIME = 0.035
            private constant real Cloud_LENGTH = Cloud_SPEED * Cloud_UPDATE_TIME

            private Cloud_Data array DS
            private integer DS_AMOUNT
        endglobals

        public function Cloud_Ending takes Cloud_Data d, timer durationTimer returns nothing
            local timer dropTimer = d.dropTimer
            local unit dummyUnit = d.dummyUnit
            local integer iteration
            local timer lightningTimer = d.lightningTimer
            local timer moveTimer = d.moveTimer
            call d.destroy()
            call FlushAttachedInteger( dropTimer, Cloud_SCOPE_ID )
            call DestroyTimerWJ( dropTimer )
            set dropTimer = null
            call SetUnitAnimationByIndex( dummyUnit, 2 )
            call RemoveUnitTimed( dummyUnit, 0.5 )
            set dummyUnit = null
            call FlushAttachedInteger( durationTimer, Cloud_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedInteger( lightningTimer, Cloud_SCOPE_ID )
            call DestroyTimerWJ( lightningTimer )
            set lightningTimer = null
            call FlushAttachedInteger( moveTimer, Cloud_SCOPE_ID )
            call DestroyTimerWJ( moveTimer )
            set moveTimer = null
            set DS_AMOUNT = DS_AMOUNT - 1
            set iteration = DS_AMOUNT
            loop
                exitwhen (DS[iteration] == d)
            endloop
            set DS[iteration] = DS[DS_AMOUNT]
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

        //! runtextmacro Scope("Lightning")
            globals
                private constant real Lightning_AREA_RANGE = 125.
                private constant real Lightning_DAMAGE = 20.
                private group Lightning_ENUM_GROUP
                private constant real Lightning_HIT_DELAY = 0.85
                private constant real Lightning_LIGHTNING_EFFECT_DURATION = 1.5
                private constant string Lightning_LIGHTNING_EFFECT_PATH = "Abilities\\Spells\\Other\\Monsoon\\MonsoonBoltTarget.mdl"
                private constant string Lightning_SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
                private constant real Lightning_STUN_DURATION = 3.
                private constant real Lightning_STUN_HERO_DURATION = 1.5
                private boolexpr Lightning_TARGET_CONDITIONS
            endglobals

            private struct Lightning_Data
                real targetX
                real targetY
            endstruct

            private function Lightning_TargetConditions takes nothing returns boolean
                set FILTER_UNIT_SELF = GetFilterUnit()
                if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                    return false
                endif
                if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
                    return false
                endif
                if ( GetUnitInvulnerability( GetUnit(FILTER_UNIT_SELF) ) > 0 ) then
                    return false
                endif
                return true
            endfunction

            private function Lightning_Ending takes nothing returns nothing
                local real duration
                local timer durationTimer = GetExpiredTimer()
                local Lightning_Data d = GetAttachedInteger(durationTimer, Lightning_SCOPE_ID)
                local Unit enumUnit
                local unit enumUnitSelf
                local real targetX = d.targetX
                local real targetY = d.targetY
                call d.destroy()
                call FlushAttachedInteger( durationTimer, Lightning_SCOPE_ID )
                call DestroyTimerWJ( durationTimer )
                set durationTimer = null
                call DestroyEffectTimed( AddSpecialEffectWJ( Lightning_SPECIAL_EFFECT_PATH, targetX, targetY ), 0.5 )
                call GroupEnumUnitsInRangeWithCollision( Lightning_ENUM_GROUP, targetX, targetY, Lightning_AREA_RANGE, Lightning_TARGET_CONDITIONS )
                set enumUnitSelf = FirstOfGroup(Lightning_ENUM_GROUP)
                if ( enumUnitSelf != null ) then
                    loop
                        set enumUnit = GetUnit(enumUnitSelf)
                        call GroupRemoveUnit( Lightning_ENUM_GROUP, enumUnitSelf )
                        if ( IsUnitType( enumUnitSelf, UNIT_TYPE_HERO ) ) then
                            set duration = Lightning_STUN_HERO_DURATION
                        else
                            set duration = Lightning_STUN_DURATION
                        endif
                        call SetUnitStunTimed( enumUnit, 1, duration )
                        call UnitDamageUnitBySpell( enumUnit, enumUnit, Lightning_DAMAGE )
                        set enumUnitSelf = FirstOfGroup( Lightning_ENUM_GROUP )
                        exitwhen ( enumUnitSelf == null )
                    endloop
                endif
            endfunction

            public function Lightning_Start takes unit dummyUnit, real targetX, real targetY returns nothing
                local real angle = GetRandomRealWJ( 0, 2 * PI )
                local real length = GetRandomReal( 0, Cloud_SIZE )
                local Lightning_Data d = Lightning_Data.create()
                local timer durationTimer = CreateTimerWJ()
                set targetX = targetX + length * Cos( angle )
                set targetY = targetY + length * Sin( angle )
                if ( GetRandomInt( 0, 0 ) == 0 ) then
                    call PlaySoundFromTypeAtPosition( LIGHTNING_IMPACT_SOUND_TYPE, targetX, targetY, GetFloorHeight( targetX, targetY ) )
                endif
                set d.targetX = targetX
                set d.targetY = targetY
                call AttachInteger(durationTimer, Lightning_SCOPE_ID, d)
                call DestroyEffectTimed( AddSpecialEffectWJ( Lightning_LIGHTNING_EFFECT_PATH, targetX, targetY ), Lightning_LIGHTNING_EFFECT_DURATION )
                call TimerStart( durationTimer, Lightning_HIT_DELAY, false, function Lightning_Ending )
                set durationTimer = null
            endfunction

            public function Lightning_Init takes nothing returns nothing
                set Lightning_ENUM_GROUP = CreateGroupWJ()
                set Lightning_TARGET_CONDITIONS = ConditionWJ( function Lightning_TargetConditions )
                call InitEffectType( Lightning_LIGHTNING_EFFECT_PATH )
                call InitEffectType( Lightning_SPECIAL_EFFECT_PATH )
            endfunction
        //! runtextmacro Endscope()

        private function Cloud_Lightning takes nothing returns nothing
            local timer lightningTimer = GetExpiredTimer()
            local Cloud_Data d = GetAttachedInteger(lightningTimer, Cloud_SCOPE_ID)
            call TimerStart( lightningTimer, GetRandomReal( Cloud_MIN_LIGHTNING_INTERVAL, Cloud_MAX_LIGHTNING_INTERVAL ), false, function Cloud_Lightning )
            set lightningTimer = null
            call Lightning_Lightning_Start( d.dummyUnit, d.x, d.y )
        endfunction

        private function Cloud_Drop takes nothing returns nothing
            local timer dropTimer = GetExpiredTimer()
            local Cloud_Data d = GetAttachedInteger(dropTimer, Cloud_SCOPE_ID)
            local real angle = GetRandomReal( 0, 2 * PI )
            local real length = GetRandomReal( 0, Cloud_DROP_AREA_RANGE )
            local real targetX = d.x + length * Cos( angle )
            local real targetY = d.y + length * Sin( angle )
            set dropTimer = null
            call DestroyEffectTimed( AddSpecialEffectWJ( Cloud_DROP_EFFECT_PATH, targetX, targetY ), Cloud_DROP_DURATION )
        endfunction

        private function Cloud_Move takes nothing returns nothing
            local timer moveTimer = GetExpiredTimer()
            local Cloud_Data d = GetAttachedInteger(moveTimer, Cloud_SCOPE_ID)
            local unit dummyUnit = d.dummyUnit
            local real x = d.x + d.lengthX
            local real y = d.y + d.lengthY
            set d.x = x
            set d.y = y
            call SetUnitX( dummyUnit, x )
            call SetUnitY( dummyUnit, y )
            set dummyUnit = null
        endfunction

        public function Cloud_Start takes nothing returns nothing
            local real angle
            local Cloud_Data d = Cloud_Data.create()
            local timer dropTimer = CreateTimerWJ()
            local unit dummyUnit
            local timer durationTimer = CreateTimerWJ()
            local integer iteration = 0
            local timer lightningTimer = CreateTimerWJ()
            local real maxDuration
            local timer moveTimer = CreateTimerWJ()
            local integer random = GetRandomInt( 0, 1 )
            local real sourceX
            local real sourceY
            local real targetX
            local real targetY
            if ( random == 0 ) then
                set random = GetRandomInt( 0, 1 )
                if ( random == 0 ) then
                    set sourceX = PLAY_RECT_MIN_X
                    set targetX = PLAY_RECT_MAX_X
                else
                    set sourceX = PLAY_RECT_MAX_X
                    set targetX = PLAY_RECT_MIN_X
                endif
                set sourceY = GetRandomReal( PLAY_RECT_MIN_Y, PLAY_RECT_MAX_Y )
                set targetY = GetRandomReal( PLAY_RECT_MIN_Y, PLAY_RECT_MAX_Y )
            else
                set random = GetRandomInt( 0, 1 )
                if ( random == 0 ) then
                    set sourceY = PLAY_RECT_MIN_Y
                    set targetY = PLAY_RECT_MAX_Y
                else
                    set sourceY = PLAY_RECT_MAX_Y
                    set targetY = PLAY_RECT_MIN_Y
                endif
                set sourceX = GetRandomReal( PLAY_RECT_MIN_X, PLAY_RECT_MAX_X )
                set targetX = GetRandomReal( PLAY_RECT_MIN_X, PLAY_RECT_MAX_X )
            endif
            set angle = Atan2( targetY - sourceY, targetX - sourceX )
            set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Cloud_DUMMY_UNIT_ID, sourceX, sourceY, STANDARD_ANGLE )
            set maxDuration = DistanceByCoordinates( sourceX, sourceY, targetX, targetY ) / Cloud_SPEED
            set d.dropTimer = dropTimer
            set d.dummyUnit = dummyUnit
            set d.durationTimer = durationTimer
            set d.lengthX = Cloud_LENGTH * Cos(angle)
            set d.lengthY = Cloud_LENGTH * Sin(angle)
            set d.lightningTimer = lightningTimer
            set d.moveTimer = moveTimer
            set d.x = sourceX
            set d.y = sourceY
            loop
                exitwhen ( iteration > 11 )
                call UnitShareVision( dummyUnit, PlayerWJ( iteration ), true )
                set iteration = iteration + 1
            endloop
            set dummyUnit = null
            call AttachInteger( durationTimer, Cloud_SCOPE_ID, d )
            call AttachInteger( dropTimer, Cloud_SCOPE_ID, d )
            call AttachInteger( lightningTimer, Cloud_SCOPE_ID, d )
            call AttachInteger( moveTimer, Cloud_SCOPE_ID, d )
            set DS[DS_AMOUNT] = d
            set DS_AMOUNT = DS_AMOUNT + 1
            call TimerStart( dropTimer, Cloud_DROP_INTERVAL, true, function Cloud_Drop )
            set dropTimer = null
            call TimerStart( moveTimer, Cloud_UPDATE_TIME, true, function Cloud_Move )
            set moveTimer = null
            call TimerStart( lightningTimer, GetRandomReal( Cloud_MIN_LIGHTNING_INTERVAL, Cloud_MAX_LIGHTNING_INTERVAL ), false, function Cloud_Lightning )
            set lightningTimer = null
            call TimerStart( durationTimer, GetRandomReal( maxDuration / 2, maxDuration ), false, function Cloud_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Cloud_Init takes nothing returns nothing
            call InitEffectType( Cloud_DROP_EFFECT_PATH )
            call InitUnitType(Cloud_DUMMY_UNIT_ID)
            call Lightning_Lightning_Init()
        endfunction
    //! runtextmacro Endscope()

    function Rain_Ending takes nothing returns nothing
        call EnableWeatherEffectTimed( EFFECT_WEATHER_EFFECT, null, false, EFFECT_WEATHER_EFFECT_FADE_OUT )
        return
        call Cloud_Cloud_EndingByEnding()
        call StopSound( EFFECT_SOUND, false, true )
    endfunction

    private function Interval takes nothing returns nothing
        call TimerStart( INTERVAL_TIMER, GetRandomReal( MIN_INTERVAL, MAX_INTERVAL ), false, function Interval )
        call Cloud_Cloud_Start()
    endfunction

    public function Start takes nothing returns nothing
        call DisplayTextTimedWJ( "Rain", 15, GetLocalPlayer() )
        call EnableWeatherEffectWJ( EFFECT_WEATHER_EFFECT, null, true )
        return
        call StartSound( EFFECT_SOUND )
        call TimerStart( INTERVAL_TIMER, GetRandomReal( MIN_INTERVAL, MAX_INTERVAL ), false, function Interval )
    endfunction

    public function Init takes nothing returns nothing
        set EFFECT_SOUND = CreateSoundFromType( RAIN_SOUND_TYPE )
        set EFFECT_WEATHER_EFFECT = AddWeatherEffectWJ( PLAY_RECT, EFFECT_WEATHER_EFFECT_PATH )
        call SetSoundVolume( EFFECT_SOUND, 127 )
        call Cloud_Cloud_Init()
    endfunction
//! runtextmacro Endscope()