//TESH.scrollpos=74
//TESH.alwaysfold=0
//! runtextmacro Scope("FuneralFeast")
    globals
        public constant integer SPELL_ID = 'A06U'

        private constant real AREA_RANGE = 500.
        private boolexpr CASTER_CONDITIONS
        private constant integer DUMMY_UNIT_ID = 'n02N'
        private group ENUM_GROUP
        private constant real RELATIVE_BONUS_ATTRIBUTES = 0.05
        private constant real RELATIVE_BONUS_ATTRIBUTES_PER_INTELLIGENCE_POINT = 0.0005
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = 800 * UPDATE_TIME
    endglobals

    private struct Data
        real bonusRelativeAttributes
        Unit caster
        real casterX
        real casterY
        real casterZ
        unit dummyUnit
        timer moveTimer
        real x
        real y
        real z
    endstruct

    private function Ending takes Unit caster, Data d, unit dummyUnit, boolean isCasterNotNull, timer moveTimer returns nothing
        local integer casterId = caster.id
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call RemoveUnitTimed( dummyUnit, 1 )
        call FlushAttachedInteger( moveTimer, FuneralFeast_SCOPE_ID )
        if ( isCasterNotNull ) then
            call RemoveIntegerFromTableById( casterId, FuneralFeast_SCOPE_ID, d )
            if ( CountIntegersInTableById( casterId, FuneralFeast_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "casterId", "EVENT_CASTER_DEATH" )
            endif
        endif
        call DestroyTimerWJ( moveTimer )
    endfunction

    private function CasterConditions_Single takes unit checkingUnit returns boolean
        if ( GetUnitState( checkingUnit, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        return true
    endfunction

    //! runtextmacro Scope("Buff")
        globals
            private constant string Buff_CASTER_EFFECT_PATH = "Abilities\\Weapons\\ProcMissile\\ProcMissile.mdl"
            private constant string Buff_CASTER_EFFECT_ATTACHMENT_POINT = "origin"
            private constant string Buff_CASTER_EFFECT2_PATH = "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl"
            private constant string Buff_CASTER_EFFECT2_ATTACHMENT_POINT = "chest"
            private constant real Buff_DURATION = 10.
            private constant integer Buff_MAX_LEVEL = 4
        endglobals

        private struct Buff_Data
            real bonusAgility
            real bonusIntelligence
            real bonusStrength
            Unit caster
            effect array casterEffects[Buff_MAX_LEVEL]
            timer durationTimer
            integer level
        endstruct

        private function Buff_Ending takes Unit caster, Buff_Data d, timer durationTimer returns nothing
            local real bonusAgility = -d.bonusAgility
            local real bonusIntelligence = -d.bonusIntelligence
            local real bonusStrength = -d.bonusStrength
            local effect array casterEffects
            local integer casterId = caster.id
            local UnitType casterType = caster.type
            local integer level = d.level
            local integer iteration = level
            loop
                set casterEffects[iteration] = d.casterEffects[iteration]
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            set iteration = level
            call d.destroy()
            call FlushAttachedIntegerById( casterId, Buff_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "Buff_EVENT_DEATH" )
            call FlushAttachedInteger( durationTimer, Buff_SCOPE_ID )
            loop
                call DestroyEffectWJ( casterEffects[iteration] )
                set casterEffects[iteration] = null
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
            call DestroyTimerWJ( durationTimer )
            call AddHeroAgilityBonus( caster, casterType, bonusAgility )
            call AddHeroIntelligenceBonus( caster, casterType, bonusIntelligence )
            call AddHeroStrengthBonus( caster, casterType, bonusStrength )
        endfunction

        public function Buff_Death takes Unit caster returns nothing
            local Buff_Data d = GetAttachedIntegerById(caster.id, Buff_SCOPE_ID)
            if ( d != NULL ) then
                call Buff_Ending( caster, d, d.durationTimer )
            endif
        endfunction

        private function Buff_Death_Event takes nothing returns nothing
            call Buff_Death( DYING_UNIT )
        endfunction

        private function Buff_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(durationTimer, Buff_SCOPE_ID)
            call Buff_Ending( d.caster, d, durationTimer )
            set durationTimer = null
        endfunction

        public function Buff_Start takes real bonusRelativeAttributes, Unit caster returns nothing
            local real bonusAgility
            local real bonusIntelligence
            local real bonusStrength
            local integer casterId
            local unit casterSelf = caster.self
            local UnitType casterType
            local Buff_Data d
            local timer durationTimer
            local boolean isNew
            local integer level
            if ( CasterConditions_Single( casterSelf ) ) then
                set casterId = caster.id
                set d = GetAttachedIntegerById( casterId, Buff_SCOPE_ID )
                set isNew = (d == NULL)
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( Buff_CASTER_EFFECT_PATH, casterSelf, Buff_CASTER_EFFECT_ATTACHMENT_POINT ) )
                if ( isNew ) then
                    set level = 0
                else
                    set durationTimer = d.durationTimer
                    set level = d.level
                endif
                if ( level < Buff_MAX_LEVEL ) then
                    set bonusAgility = RoundTo( GetHeroAgility( caster ) * bonusRelativeAttributes, 0.1 )
                    set bonusIntelligence = RoundTo( GetHeroIntelligence( caster ) * bonusRelativeAttributes, 0.1 )
                    set bonusStrength = RoundTo( GetHeroStrength( caster ) * bonusRelativeAttributes, 0.1 )
                    set casterType = caster.type
                    if ( isNew ) then
                        set d = Buff_Data.create()
                        set durationTimer = CreateTimerWJ()
                        set d.bonusAgility = bonusAgility
                        set d.bonusIntelligence = bonusIntelligence
                        set d.bonusStrength = bonusStrength
                        set d.caster = caster
                        set d.durationTimer = durationTimer
                        call AttachIntegerById( casterId, Buff_SCOPE_ID, d )
                        //! runtextmacro AddEventById( "casterId", "Buff_EVENT_DEATH" )
                        call AttachInteger( durationTimer, Buff_SCOPE_ID, d )
                    else
                        set d.bonusAgility = d.bonusAgility + bonusAgility
                        set d.bonusIntelligence = d.bonusIntelligence + bonusIntelligence
                        set d.bonusStrength = d.bonusStrength + bonusStrength
                    endif
                    set level = level + 1
                    set d.casterEffects[level] = AddSpecialEffectTargetWJ( Buff_CASTER_EFFECT2_PATH, casterSelf, Buff_CASTER_EFFECT2_ATTACHMENT_POINT )
                    set d.level = level
                    call AddHeroAgilityBonus( caster, casterType, bonusAgility )
                    call AddHeroIntelligenceBonus( caster, casterType, bonusIntelligence )
                    call AddHeroStrengthBonus( caster, casterType, bonusStrength )
                endif
                call TimerStart( durationTimer, Buff_DURATION, false, function Buff_EndingByTimer )
                set durationTimer = null
            endif
            set casterSelf = null
        endfunction

        public function Buff_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Buff_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Buff_Death_Event" )
            call InitEffectType( Buff_CASTER_EFFECT_PATH )
            call InitEffectType( Buff_CASTER_EFFECT2_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Caster_Death_ResetCaster takes Unit caster, real casterX, real casterY, real casterZ, Data d returns nothing
        local integer casterId = caster.id
        set d.caster = NULL
        call RemoveIntegerFromTableById( casterId, FuneralFeast_SCOPE_ID, d )
        if ( CountIntegersInTableById( casterId, FuneralFeast_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "casterId", "EVENT_CASTER_DEATH" )
        endif
        set d.casterX = casterX
        set d.casterY = casterY
        set d.casterZ = casterZ
    endfunction

    public function Caster_Death takes Unit caster, real casterX, real casterY, real casterZ returns nothing
        local integer casterId = caster.id
        local Data d
        local integer iteration = CountIntegersInTableById( casterId, FuneralFeast_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( casterId, FuneralFeast_SCOPE_ID, iteration )
                call Caster_Death_ResetCaster( caster, casterX, casterY, casterZ, d )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Caster_Death_Event takes nothing returns nothing
        local unit dyingUnitSelf = DYING_UNIT.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)
        call Caster_Death( DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) )
        set dyingUnitSelf = null
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local real bonusRelativeAttributes
        local unit casterSelf
        local real casterX
        local real casterY
        local real casterZ
        local real distanceX
        local real distanceY
        local real distanceZ
        local boolean isCasterNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, FuneralFeast_SCOPE_ID)
        local Unit caster = d.caster
        local unit dummyUnit = d.dummyUnit
        local boolean isCasterNull = ( caster == NULL )
        local boolean reachesCaster
        local real x = d.x
        local real y = d.y
        local real z = d.z
        if ( isCasterNull ) then
            set casterX = d.casterX
            set casterY = d.casterY
            set casterZ = d.casterZ
        else
            set casterSelf = caster.self
            set casterX = GetUnitX( casterSelf )
            set casterY = GetUnitY( casterSelf )
            set casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitImpactZ(caster)
            set casterSelf = null
        endif
        set reachesCaster = ( DistanceByCoordinatesWithZ( x, y, z, casterX, casterY, casterZ ) <= LENGTH )
        if ( reachesCaster ) then
            set x = casterX
            set y = casterY
            set z = casterZ
        else
            set distanceZ = casterZ - z
            set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( x, y, casterX, casterY ) )
            set distanceX = casterX - x
            set distanceY = casterY - y
            set angleXY = Atan2( distanceY, distanceX )
            set lengthXY = LENGTH * Cos( angleLengthXYZ )
            set x = x + lengthXY * Cos( angleXY )
            set y = y + lengthXY * Sin( angleXY )
            set z = z + LENGTH * Sin( angleLengthXYZ )
            call SetUnitFacingWJ( dummyUnit, angleXY )
        endif
        call SetUnitX( dummyUnit, x )
        call SetUnitY( dummyUnit, y )
        call SetUnitZ( dummyUnit, x, y, z )
        if ( reachesCaster ) then
            set bonusRelativeAttributes = d.bonusRelativeAttributes
            set isCasterNotNull = (isCasterNull == false)
            call Ending(caster, d, dummyUnit, isCasterNotNull, moveTimer)
            if ( isCasterNotNull ) then
                call Buff_Buff_Start( bonusRelativeAttributes, caster )
            endif
        else
            set d.x = x
            set d.y = y
            set d.z = z
        endif
        set dummyUnit = null
        set moveTimer = null
    endfunction

    private function CasterConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetAttachedBooleanById( GetUnit(FILTER_UNIT_SELF).id, FuneralFeast_SCOPE_ID ) == false ) then
            return false
        endif
        if ( CasterConditions_Single( FILTER_UNIT_SELF ) == false ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        return true
    endfunction

    private function SourceConditions takes boolean deathCausedByEnemy, Unit source returns boolean
        if (deathCausedByEnemy == false) then
            return false
        endif
        set TEMP_UNIT_SELF = source.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitIllusionWJ( source ) ) then
            return false
        endif
        if ( IsUnitWard( source ) ) then
            return false
        endif
        return true
    endfunction

    public function Source_Death takes boolean deathCausedByEnemy, player killingUnitOwner, Unit source, player sourceOwner, real sourceX, real sourceY, real sourceZ returns nothing
        local Unit caster
        local integer casterId
        local unit casterSelf
        local Data d
        local unit dummyUnit
        local timer moveTimer
        if ( SourceConditions( deathCausedByEnemy, source ) ) then
            set TEMP_PLAYER = killingUnitOwner
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, sourceX, sourceY, AREA_RANGE, CASTER_CONDITIONS )
            set casterSelf = GetNearestUnit( ENUM_GROUP, sourceX, sourceY )
            if ( casterSelf != null ) then
                set caster = GetUnit(casterSelf)
                set casterId = caster.id
                set d = Data.create()
                set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, sourceX, sourceY, Atan2( GetUnitY(casterSelf) - sourceY, GetUnitX(casterSelf) - sourceX ) )
                set casterSelf = null
                set moveTimer = CreateTimerWJ()
                set d.bonusRelativeAttributes = RELATIVE_BONUS_ATTRIBUTES + GetHeroIntelligenceTotal( caster ) * RELATIVE_BONUS_ATTRIBUTES_PER_INTELLIGENCE_POINT
                set d.caster = caster
                set d.dummyUnit = dummyUnit
                set d.moveTimer = moveTimer
                set d.x = sourceX
                set d.y = sourceY
                set d.z = sourceZ
                call AddIntegerToTableById( casterId, FuneralFeast_SCOPE_ID, d )
                if ( CountIntegersInTableById( casterId, FuneralFeast_SCOPE_ID ) == TABLE_STARTED ) then
                    //! runtextmacro AddEventById( "casterId", "EVENT_CASTER_DEATH" )
                endif
                call AttachInteger( moveTimer, FuneralFeast_SCOPE_ID, d )
                call SetUnitZ(dummyUnit, sourceX, sourceY, sourceZ)
                set dummyUnit = null
                call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
                set moveTimer = null
            endif
        endif
    endfunction

    private function Source_Death_Event takes nothing returns nothing
        local player dyingUnitOwner = DYING_UNIT.owner
        local unit dyingUnitSelf = DYING_UNIT.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)
        call Source_Death( IsUnitEnemy(KILLING_UNIT.self, dyingUnitOwner), KILLING_UNIT.owner, DYING_UNIT, dyingUnitOwner, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) + GetUnitOutpactZ(DYING_UNIT) )
        set dyingUnitOwner = null
        set dyingUnitSelf = null
    endfunction

    public function Learn takes Unit caster returns nothing
        call AttachBooleanById( caster.id, FuneralFeast_SCOPE_ID, true )
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set CASTER_CONDITIONS = ConditionWJ( function CasterConditions )
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_CASTER_DEATH", "UnitDies_EVENT_KEY", "0", "function Caster_Death_Event" )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call SetAbilityRequiredResearch( SPELL_ID, SecondaryTalent_RESEARCH_ID )
    //    call AddNewSavedEvent( "MainIntegers", UnitDies_EVENT_STRING_KEY, 0, function Source_Death_Event )
        call Buff_Buff_Init()
    endfunction
//! runtextmacro Endscope()