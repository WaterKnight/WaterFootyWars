//TESH.scrollpos=267
//TESH.alwaysfold=0
//! runtextmacro Scope("UtilizationOfRests")
    globals
        public constant integer SPELL_ID = 'A079'

        private constant real AREA_RANGE = 500.
        private boolexpr CASTER_CONDITIONS
        private real array CHANCE
        private real array CHANCE_PER_AGILITY_POINT
        private group ENUM_GROUP
        private constant integer MAX_MAX_SERVANTS_AMOUNT = 5
        private integer array MAX_SERVANTS_AMOUNT
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Undead\\RaiseSkeletonWarrior\\RaiseSkeleton.mdl"
    endglobals

    private struct Data
        integer abilityLevel
        Unit array servants[MAX_MAX_SERVANTS_AMOUNT]
        integer servantsAmount
    endstruct

    //! runtextmacro Scope("Servant")
        globals
            private real array Servant_DURATION
            private integer array Servant_SUMMON_UNIT_ID
        endglobals

        private struct Servant_Data
            Data d
            integer index
        endstruct

        //! runtextmacro Scope("Release")
            globals
                private constant real Release_RELEASE_TIME = 1.2
            endglobals

            private struct Release_Data
                integer abilityLevel
                timer releaseTimer
                Unit servant
            endstruct

            private function Release_Ending takes Release_Data d, timer releaseTimer, Unit servant returns nothing
                local integer servantId = servant.id
                call d.destroy()
                call FlushAttachedInteger( releaseTimer, Release_SCOPE_ID )
                call DestroyTimerWJ( releaseTimer )
                call FlushAttachedIntegerById(servantId, Release_SCOPE_ID)
                //! runtextmacro RemoveEventById( "servantId", "Release_EVENT_DEATH" )
            endfunction

            public function Release_Death takes Unit servant returns nothing
                local Release_Data d = GetAttachedIntegerById(servant.id, Release_SCOPE_ID)
                if (d != NULL) then
                    call Release_Ending(d, d.releaseTimer, servant)
                endif
            endfunction

            private function Release_Death_Event takes nothing returns nothing
                call Release_Death(DYING_UNIT)
            endfunction

            private function Release_EndingByTimer takes nothing returns nothing
                local timer releaseTimer = GetExpiredTimer()
                local Release_Data d = GetAttachedInteger(releaseTimer, Release_SCOPE_ID)
                local integer abilityLevel = d.abilityLevel
                local Unit servant = d.servant
                local unit servantSelf = servant.self
                call Release_Ending(d, releaseTimer, servant)
                set releaseTimer = null
                call SetUnitBlendTime( servantSelf, 0.15 )
                call SetUnitTimeScale( servantSelf, 1 )
                call SetUnitAnimationByIndex( servantSelf, 0 )
                call PauseUnit( servantSelf, false )
                call SetUnitInvulnerable( servantSelf, false )
                call UnitApplyTimedLifeWJ( servantSelf, Servant_DURATION[abilityLevel] )
                set servantSelf = null
            endfunction

            public function Release_Start takes integer abilityLevel, Unit servant returns nothing
                local Release_Data d = Release_Data.create()
                local timer releaseTimer = CreateTimerWJ()
                local integer servantId = servant.id
                local unit servantSelf = servant.self
                set d.abilityLevel = abilityLevel
                set d.releaseTimer = releaseTimer
                set d.servant = servant
                call AttachInteger( releaseTimer, Release_SCOPE_ID, d )
                call AttachIntegerById(servantId, Release_SCOPE_ID, d)
                //! runtextmacro AddEventById( "servantId", "Release_EVENT_DEATH" )
                call SetUnitBlendTime( servantSelf, 0 )
                call SetUnitTimeScale( servantSelf, 2 )
                call SetUnitAnimationByIndex( servantSelf, 5 )
                call PauseUnit( servantSelf, true )
                call SetUnitInvulnerable( servantSelf, true )
                set servantSelf = null
                call TimerStart( releaseTimer, Release_RELEASE_TIME, false, function Release_EndingByTimer )
                set releaseTimer = null
            endfunction

            public function Release_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Release_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Release_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        public function Servant_Death takes Unit servant returns nothing
            local Data d
            local integer index
            local integer servantId = servant.id
            local Servant_Data e = GetAttachedIntegerById(servantId, Servant_SCOPE_ID)
            local integer servantsAmount
            if ( e != NULL ) then
                set d = e.d
                set index = e.index
                set servantsAmount = d.servantsAmount - 1
                call e.destroy()
                set d.servants[index] = d.servants[servantsAmount]
                set d.servantsAmount = servantsAmount
                call FlushAttachedIntegerById( servantId, Servant_SCOPE_ID )
                //! runtextmacro RemoveEventById( "servantId", "Servant_EVENT_DEATH" )
            endif
        endfunction

        private function Servant_Death_Event takes nothing returns nothing
            call Servant_Death( DYING_UNIT )
        endfunction

        public function Servant_Start takes integer abilityLevel, real angle, Unit caster, Data d, real x, real y returns nothing
            local Servant_Data e = Servant_Data.create()
            local integer index = d.servantsAmount
            local Unit servant = CreateUnitEx( caster.owner, Servant_SUMMON_UNIT_ID[abilityLevel], x, y, angle )
            local integer servantId = servant.id
            local integer servantsAmount = index + 1
            set d.servants[index] = servant
            set d.servantsAmount = servantsAmount
            set e.d = d
            set e.index = servantsAmount - 1
            call AttachIntegerById( servantId, Servant_SCOPE_ID, e )
            //! runtextmacro AddEventById( "servantId", "Servant_EVENT_DEATH" )
            call Release_Release_Start(abilityLevel, servant)
        endfunction

        public function Servant_Init takes nothing returns nothing
            set Servant_DURATION[1] = 30
            set Servant_DURATION[2] = 30
            set Servant_DURATION[3] = 30
            set Servant_DURATION[4] = 30
            set Servant_DURATION[5] = 30
            //! runtextmacro CreateEvent( "Servant_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Servant_Death_Event" )
            set Servant_SUMMON_UNIT_ID[1] = ZOMBIE_LEVEL1_UNIT_ID
            set Servant_SUMMON_UNIT_ID[2] = ZOMBIE_LEVEL2_UNIT_ID
            set Servant_SUMMON_UNIT_ID[3] = ZOMBIE_LEVEL3_UNIT_ID
            set Servant_SUMMON_UNIT_ID[4] = ZOMBIE_LEVEL4_UNIT_ID
            set Servant_SUMMON_UNIT_ID[5] = ZOMBIE_LEVEL5_UNIT_ID
            call Release_Release_Init()
        endfunction
    //! runtextmacro Endscope()

    public function Caster_Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, UtilizationOfRests_SCOPE_ID)
        local integer iteration
        if (d != NULL) then
            set iteration = d.servantsAmount - 1
            loop
                call KillUnit( d.servants[iteration].self )
                set iteration = iteration - 1
                exitwhen ( iteration < 0 )
            endloop
        endif
    endfunction

    private function Caster_Death_Event takes nothing returns nothing
        call Caster_Death( DYING_UNIT )
    endfunction

    private function CasterConditions takes nothing returns boolean
        local Data d
        set FILTER_UNIT_SELF = GetFilterUnit()
        set d = GetAttachedIntegerById(GetUnit(FILTER_UNIT_SELF).id, UtilizationOfRests_SCOPE_ID)
        if ( d == NULL ) then
            return false
        endif
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( d.servantsAmount >= MAX_SERVANTS_AMOUNT[d.abilityLevel] ) then
            return false
        endif
        return true
    endfunction

    private function Source_Death_Conditions takes Unit source returns boolean
        if ( GetUnitCanNotBeRevived(source) > 0 ) then
            return false
        endif
        set TEMP_UNIT_SELF = source.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_HERO ) ) then
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

    public function Source_Death takes Unit source, real sourceX, real sourceY returns nothing
        local integer abilityLevel
        local Unit enumUnit
        local unit enumUnitSelf
        local boolean found
        local real sourceAngle
        if ( Source_Death_Conditions( source ) ) then
            set found = false
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, sourceX, sourceY, AREA_RANGE, CASTER_CONDITIONS )
            set enumUnitSelf = GetNearestUnit( ENUM_GROUP, sourceX, sourceY )
            if (enumUnitSelf != null) then
                loop
                    set abilityLevel = GetUnitAbilityLevel(enumUnitSelf, SPELL_ID)
                    set enumUnit = GetUnit(enumUnitSelf)
                    call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                    if ( GetRandomReal( 0.01, 1 ) < CHANCE[abilityLevel] + GetHeroAgilityTotal( enumUnit ) * CHANCE_PER_AGILITY_POINT[abilityLevel] ) then
                        set found = true
                        set sourceAngle = GetUnitFacingWJ( source.self )
                        call RemoveUnitEx( source )
                        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, sourceX, sourceY ) )
                        call Servant_Servant_Start(abilityLevel, sourceAngle, enumUnit, GetAttachedIntegerById(enumUnit.id, UtilizationOfRests_SCOPE_ID), sourceX, sourceY )
                    endif
                    exitwhen (found)
                    set enumUnitSelf = GetNearestUnit( ENUM_GROUP, sourceX, sourceY )
                    exitwhen ( enumUnitSelf == null )
                endloop
                if (found) then
                    set enumUnitSelf = null
                endif
            endif
        endif
    endfunction

    private function Source_Death_Event takes nothing returns nothing
        local unit dyingUnitSelf = DYING_UNIT.self
        call Source_Death( DYING_UNIT, GetUnitX(dyingUnitSelf), GetUnitY(dyingUnitSelf) )
        set dyingUnitSelf = null
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, UtilizationOfRests_SCOPE_ID)
        if (d == NULL) then
            set d = Data.create()
            call AttachIntegerById(casterId, UtilizationOfRests_SCOPE_ID, d)
        endif
        set d.abilityLevel = GetUnitAbilityLevel(caster.self, SPELL_ID)
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set CASTER_CONDITIONS = ConditionWJ( function CasterConditions )
        set CHANCE[1] = 0.3
        set CHANCE[2] = 0.3
        set CHANCE[3] = 0.3
        set CHANCE[4] = 0.3
        set CHANCE[5] = 0.3
        set CHANCE_PER_AGILITY_POINT[1] = 0.003
        set CHANCE_PER_AGILITY_POINT[2] = 0.003
        set CHANCE_PER_AGILITY_POINT[3] = 0.003
        set CHANCE_PER_AGILITY_POINT[4] = 0.003
        set CHANCE_PER_AGILITY_POINT[5] = 0.003
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_CASTER_DEATH", "UnitDies_EVENT_KEY", "0", "function Caster_Death_Event" )
        set MAX_SERVANTS_AMOUNT[1] = 4
        set MAX_SERVANTS_AMOUNT[2] = 4
        set MAX_SERVANTS_AMOUNT[3] = 4
        set MAX_SERVANTS_AMOUNT[4] = 4
        set MAX_SERVANTS_AMOUNT[5] = 4
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Servant_Servant_Init()
    endfunction
//! runtextmacro Endscope()