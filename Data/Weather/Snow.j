//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Snow")
    globals
        private weathereffect EFFECT_WEATHER_EFFECT
        private constant real EFFECT_WEATHER_EFFECT_FADE_OUT = 3
        private constant integer EFFECT_WEATHER_EFFECT_PATH = 'SNls'
        private timer INTERVAL_TIMER
        private constant real MAX_INTERVAL = 7.
        private constant real MIN_INTERVAL = 5.
    endglobals

    public function Ending takes nothing returns nothing
        call EnableWeatherEffectTimed( EFFECT_WEATHER_EFFECT, null, false, EFFECT_WEATHER_EFFECT_FADE_OUT )
        return
        call SetCineFilterTextureWJ( GetLocalPlayer(), "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp" )
        call SetCineFilterBlendModeWJ( GetLocalPlayer(), BLEND_MODE_BLEND )
        call SetCineFilterTexMapFlagsWJ( GetLocalPlayer(), TEXMAP_FLAG_NONE )
        call SetCineFilterUVWJ( GetLocalPlayer(), 0, 0, 1, 1 )
        call SetCineFilterColorWJ( GetLocalPlayer(), 0, 0, 0, 0 )
        call DisplayCineFilterWJ( GetLocalPlayer(), true )
    endfunction

    //! runtextmacro Scope("Ghost")
        globals
            private constant real Ghost_AREA_RANGE = 250.
            private constant real Ghost_BURN_INTERVAL = 0.25
            private constant real Ghost_BURNED_MANA = 40.
            private constant integer Ghost_DUMMY_UNIT_ID = 'n00Q'
            private constant real Ghost_DUMMY_UNIT_OUTPACT_Z = 60
            private constant real Ghost_EFFECT_LIGHTNING_DURATION = 1.5
            private group Ghost_ENUM_GROUP
            private constant real Ghost_SPEED = 250.
            private constant real Ghost_UPDATE_TIME = 0.035
            private constant real Ghost_LENGTH = Ghost_SPEED * Ghost_UPDATE_TIME
            private boolexpr Ghost_TARGET_CONDITIONS
        endglobals

        private struct Ghost_Data
            timer burnTimer
            unit dummyUnit
            real lengthX
            real lengthY
            group targetGroup
            timer updateTimer
            real x
            real y
        endstruct

        //! runtextmacro Scope("EffectLightning")
            globals
                private constant string EffectLightning_EFFECT_LIGHTNING_PATH = "MBUR"
                private constant real EffectLightning_UPDATE_TIME = 0.035
            endglobals

            private struct EffectLightning_Data
                Ghost_Data d
                lightning effectLightning
                Unit target
                real targetX
                real targetY
                real targetZ
                timer updateTimer
            endstruct

            private function EffectLightning_Ending takes EffectLightning_Data d, lightning effectLightning, unit source, Unit target returns nothing
                local integer targetId
                local timer updateTimer = d.updateTimer
                call d.destroy()
                call FlushAttachedInteger(effectLightning, EffectLightning_SCOPE_ID)
                if (source != null) then
                    call RemoveIntegerFromTable(source, EffectLightning_SCOPE_ID, d)
                endif
                if (target != NULL) then
                    set targetId = target.id
                    call RemoveIntegerFromTableById(targetId, EffectLightning_SCOPE_ID, d)
                    if (CountIntegersInTableById(targetId, EffectLightning_SCOPE_ID) == TABLE_EMPTY) then
                        //! runtextmacro RemoveEventById( "targetId", "EffectLightning_EVENT_TARGET_DEATH" )
                    endif
                endif
                call DestroyTimerWJ(updateTimer)
                set updateTimer = null
            endfunction

            public function EffectLightning_EffectLightning_Death takes lightning effectLightning returns nothing
                local EffectLightning_Data d = GetAttachedInteger(effectLightning, EffectLightning_SCOPE_ID)
                if (d != NULL) then
                    call EffectLightning_Ending(d, effectLightning, d.d.dummyUnit, d.target)
                endif
            endfunction

            public function EffectLightning_Source_Death takes unit source returns nothing
                local EffectLightning_Data d
                local integer iteration = CountIntegersInTable(source, EffectLightning_SCOPE_ID)
                if (iteration > TABLE_EMPTY) then
                    loop
                        set d = GetIntegerFromTable(source, EffectLightning_SCOPE_ID, iteration)
                        call EffectLightning_Ending(d, d.effectLightning, source, d.target)
                        set iteration = iteration - 1
                        exitwhen (iteration < TABLE_STARTED)
                    endloop
                endif
            endfunction

            public function EffectLightning_Target_Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
                local EffectLightning_Data d
                local integer targetId = target.id
                local integer iteration = CountIntegersInTableById(targetId, EffectLightning_SCOPE_ID)
                if (iteration > TABLE_EMPTY) then
                    loop
                        set d = GetIntegerFromTableById(targetId, EffectLightning_SCOPE_ID, iteration)
                        set d.targetX = targetX
                        set d.targetY = targetY
                        set d.targetZ = targetZ + GetUnitImpactZ(target)
                        call RemoveIntegerFromTableById(targetId, EffectLightning_SCOPE_ID, d)
                        if (CountIntegersInTableById(targetId, EffectLightning_SCOPE_ID) == TABLE_EMPTY) then
                            //! runtextmacro RemoveEventById( "targetId", "EffectLightning_EVENT_TARGET_DEATH" )
                        endif
                        set iteration = iteration - 1
                        exitwhen (iteration < TABLE_STARTED)
                    endloop
                endif
            endfunction

            private function EffectLightning_Target_Death_Event takes nothing returns nothing
                local unit dyingUnitSelf = DYING_UNIT.self
                local real dyingUnitX = GetUnitX(dyingUnitSelf)
                local real dyingUnitY = GetUnitY(dyingUnitSelf)
                call EffectLightning_Target_Death(DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY))
                set dyingUnitSelf = null
            endfunction

            private function EffectLightning_Move takes nothing returns nothing
                local timer updateTimer = GetExpiredTimer()
                local EffectLightning_Data d = GetAttachedInteger(updateTimer, EffectLightning_SCOPE_ID)
                local Ghost_Data e = d.d
                local unit source = e.dummyUnit
                local real sourceX = e.x
                local real sourceY = e.y
                local real sourceZ = GetUnitZ( source, sourceX, sourceY )
                local Unit target = d.target
                local unit targetSelf
                local real targetX
                local real targetY
                local real targetZ
                set updateTimer = null
                if ( target == NULL ) then
                    set targetX = d.targetX
                    set targetY = d.targetY
                    set targetZ = d.targetZ
                else
                    set targetSelf = target.self
                    set targetX = GetUnitX( targetSelf )
                    set targetY = GetUnitY( targetSelf )
                    set targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target)
                    set targetSelf = null
                endif
                call MoveLightningEx( d.effectLightning, true, sourceX, sourceY, sourceZ + Ghost_DUMMY_UNIT_OUTPACT_Z, targetX, targetY, targetZ )
            endfunction

            public function EffectLightning_Start takes Ghost_Data e, unit dummyUnit, real sourceX, real sourceY, real sourceZ, Unit target, real targetX, real targetY, real targetZ returns lightning
                local EffectLightning_Data d = EffectLightning_Data.create()
                local real dummyUnitX = GetUnitX(dummyUnit)
                local real dummyUnitY = GetUnitY(dummyUnit)
                local integer targetId = target.id
                local lightning effectLightning = AddLightningWJ( EffectLightning_EFFECT_LIGHTNING_PATH, sourceX, sourceY, sourceZ, targetX, targetY, targetZ + GetUnitImpactZ(target) )
                local timer updateTimer = CreateTimerWJ()
                set d.d = e
                set d.effectLightning = effectLightning
                set d.target = target
                call AddIntegerToTable( dummyUnit, EffectLightning_SCOPE_ID, d )
                call AttachInteger( effectLightning, EffectLightning_SCOPE_ID, d )
                call AddIntegerToTableById( targetId, EffectLightning_SCOPE_ID, d )
                if ( CountIntegersInTableById(targetId, EffectLightning_SCOPE_ID) == TABLE_STARTED) then
                    //! runtextmacro AddEventById( "targetId", "EffectLightning_EVENT_TARGET_DEATH" )
                endif
                call AttachInteger( updateTimer, EffectLightning_SCOPE_ID, d )
                call TimerStart( updateTimer, EffectLightning_UPDATE_TIME, true, function EffectLightning_Move )
                set updateTimer = null
                set TEMP_LIGHTNING = effectLightning
                set effectLightning = null
                return TEMP_LIGHTNING
            endfunction

            public function EffectLightning_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "EffectLightning_EVENT_TARGET_DEATH", "UnitDies_EVENT_KEY", "0", "function EffectLightning_Target_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        private function Ghost_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Ghost_Data d = GetAttachedInteger(durationTimer, Ghost_SCOPE_ID)
            local timer burnTimer = d.burnTimer
            local unit dummyUnit = d.dummyUnit
            local group targetGroup = d.targetGroup
            local timer updateTimer = d.updateTimer
            call d.destroy()
            call FlushAttachedInteger( burnTimer, Ghost_SCOPE_ID )
            call DestroyTimerWJ( burnTimer )
            set burnTimer = null
            call FlushAttachedInteger( durationTimer, Ghost_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            call SetUnitAnimationByIndex( dummyUnit, 4 )
            call EffectLightning_EffectLightning_Source_Death(dummyUnit)
            call RemoveUnitTimed(dummyUnit, 3)
            call DestroyGroupWJ( targetGroup )
            set targetGroup = null
            call FlushAttachedInteger( updateTimer, Ghost_SCOPE_ID )
            call DestroyTimerWJ( updateTimer )
            set updateTimer = null
        endfunction

        private function Ghost_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_MANA ) <= 0 ) then
                return false
            endif
            if ( IsUnitInGroup( FILTER_UNIT_SELF, TEMP_GROUP ) ) then
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

        private function Ghost_BurnMana takes nothing returns nothing
            local real burnedManaMax
            local timer burnTimer = GetExpiredTimer()
            local Ghost_Data d = GetAttachedInteger(burnTimer, Ghost_SCOPE_ID)
            local unit dummyUnit = d.dummyUnit
            local Unit enumUnit
            local unit enumUnitSelf
            local real enumUnitMana
            local real enumUnitX
            local real enumUnitY
            local real enumUnitZ
            local real lostMana
            local group targetGroup = d.targetGroup
            local real x = d.x
            local real y = d.y
            local real z
            set TEMP_GROUP = targetGroup
            call GroupEnumUnitsInRangeWithCollision( Ghost_ENUM_GROUP, x, y, Ghost_AREA_RANGE, Ghost_TARGET_CONDITIONS )
            set enumUnitSelf = FirstOfGroup( Ghost_ENUM_GROUP )
            if ( enumUnitSelf != null ) then
                set z = GetUnitZ(dummyUnit, x, y) + Ghost_DUMMY_UNIT_OUTPACT_Z
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    set enumUnitMana = GetUnitState( enumUnitSelf, UNIT_STATE_MANA )
                    set lostMana = Min(enumUnitMana, Ghost_BURNED_MANA)
                    set enumUnitX = GetUnitX( enumUnitSelf )
                    set enumUnitY = GetUnitY( enumUnitSelf )
                    set enumUnitZ = GetUnitZ(enumUnitSelf, enumUnitX, enumUnitY)
                    call GroupRemoveUnit( Ghost_ENUM_GROUP, enumUnitSelf )
                    call GroupAddUnit( targetGroup, enumUnitSelf )
                    call DestroyLightningTimedEx( EffectLightning_EffectLightning_Start( d, dummyUnit, x, y, z, enumUnit, enumUnitX, enumUnitY, enumUnitZ ), Ghost_EFFECT_LIGHTNING_DURATION )
                    call PlaySoundFromTypeOnUnit( SNOW_GHOST_MANA_DRAIN_SOUND_TYPE, enumUnitSelf )
                    call CreateRisingTextTag( I2S( R2I( lostMana ) ), 0.023, enumUnitX, enumUnitY, enumUnitZ + GetUnitOutpactZ(enumUnit), 40, 0, 0, 255, 255, 1, 4 )
                    call SetUnitState( enumUnitSelf, UNIT_STATE_MANA, enumUnitMana - lostMana )
                    set enumUnitSelf = FirstOfGroup( Ghost_ENUM_GROUP )
                    exitwhen ( enumUnitSelf == null )
                endloop
            endif
            set dummyUnit = null
        endfunction

        private function Ghost_Move takes nothing returns nothing
            local timer updateTimer = GetExpiredTimer()
            local Ghost_Data d = GetAttachedInteger( updateTimer, Ghost_SCOPE_ID )
            local unit dummyUnit = d.dummyUnit
            local real x = d.x + d.lengthX
            local real y = d.y + d.lengthY
            set updateTimer = null
            set d.x = x
            set d.y = y
            call SetUnitX( dummyUnit, x )
            call SetUnitY( dummyUnit, y )
            set dummyUnit = null
        endfunction

        public function Ghost_Start takes nothing returns nothing
            local real angle
            local timer burnTimer = CreateTimerWJ()
            local Ghost_Data d = Ghost_Data.create()
            local unit dummyUnit
            local timer durationTimer = CreateTimerWJ()
            local integer random = GetRandomIntWJ( 0, 1 )
            local timer updateTimer = CreateTimerWJ()
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
            set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Ghost_DUMMY_UNIT_ID, sourceX, sourceY, angle )
            set d.burnTimer = burnTimer
            set d.dummyUnit = dummyUnit
            set d.lengthX = Ghost_LENGTH * Cos(angle)
            set d.lengthY = Ghost_LENGTH * Sin(angle)
            set d.targetGroup = CreateGroupWJ()
            set d.updateTimer = updateTimer
            set d.x = sourceX
            set d.y = sourceY
            call AttachInteger(burnTimer, Ghost_SCOPE_ID, d)
            call AttachInteger(durationTimer, Ghost_SCOPE_ID, d)
            call AttachInteger(updateTimer, Ghost_SCOPE_ID, d)
            call SetUnitAnimationByIndex( dummyUnit, 5 )
            set dummyUnit = null
            call TimerStart( burnTimer, Ghost_BURN_INTERVAL, true, function Ghost_BurnMana )
            set burnTimer = null
            call TimerStart( updateTimer, Ghost_UPDATE_TIME, true, function Ghost_Move )
            set updateTimer = null
            call TimerStart( durationTimer, DistanceByCoordinates( sourceX, sourceY, targetX, targetY ) / Ghost_SPEED, false, function Ghost_Ending )
            set durationTimer = null
        endfunction

        public function Ghost_Init takes nothing returns nothing
            set Ghost_ENUM_GROUP = CreateGroupWJ()
            set Ghost_TARGET_CONDITIONS = ConditionWJ( function Ghost_TargetConditions )
            call InitUnitType(Ghost_DUMMY_UNIT_ID)
            call EffectLightning_EffectLightning_Init()
        endfunction
    //! runtextmacro Endscope()

    private function Interval takes nothing returns nothing
        call Ghost_Ghost_Start()
        call TimerStart( INTERVAL_TIMER, GetRandomReal( MIN_INTERVAL, MAX_INTERVAL ), false, function Interval )
    endfunction

    public function Start takes nothing returns nothing
        call DisplayTextTimedWJ( "Snow", 15, GetLocalPlayer() )
        call EnableWeatherEffectWJ( EFFECT_WEATHER_EFFECT, null, true )
        return
        call SetCineFilterTextureWJ( GetLocalPlayer(), "ReplaceableTextures\\CameraMasks\\DreamFilter_Mask.blp" )
        call SetCineFilterBlendModeWJ( GetLocalPlayer(), BLEND_MODE_BLEND )
        call SetCineFilterTexMapFlagsWJ( GetLocalPlayer(), TEXMAP_FLAG_NONE )
        call SetCineFilterUVWJ( GetLocalPlayer(), 0, 0, 1, 1 )
        call SetCineFilterColorWJ( GetLocalPlayer(), 160, 160, 160, 0 )
        call DisplayCineFilterWJ( GetLocalPlayer(), true )
        //call TimerStart( INTERVAL_TIMER, GetRandomReal( MIN_INTERVAL, MAX_INTERVAL ), false, function Interval )
    endfunction

    public function Init takes nothing returns nothing
        set INTERVAL_TIMER = CreateTimerWJ()
        set EFFECT_WEATHER_EFFECT = AddWeatherEffectWJ( PLAY_RECT, EFFECT_WEATHER_EFFECT_PATH )
        call Ghost_Ghost_Init()
    endfunction
//! runtextmacro Endscope()