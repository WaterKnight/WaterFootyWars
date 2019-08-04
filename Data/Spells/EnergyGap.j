//TESH.scrollpos=290
//TESH.alwaysfold=0
//! runtextmacro Scope("EnergyGap")
    globals
        public constant integer SPELL_ID = 'A00A'

        private constant integer LEVELS_AMOUNT = 5
    endglobals

    //! runtextmacro Scope("Heal")
        globals
            private constant real Heal_AREA_RANGE = 500.
            private real array Heal_CHANCE
            private constant integer Heal_DUMMY_UNIT_ID = 'n00S'
            private group Heal_ENUM_GROUP
            private group Heal_ENUM_GROUP2
            private real array Heal_LENGTH
            private real array Heal_REFRESHED_LIFE_PER_DAMAGE_POINT
            private real array Heal_REFRESHED_LIFE_PER_DAMAGE_POINT_PER_STRENGTH_POINT
            private integer array Heal_SHOTS_AMOUNT
            private real array Heal_SPEED
            private boolexpr Heal_TARGET_CONDITIONS
            private constant string Heal_TARGET_EFFECT_PATH = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
            private constant string Heal_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
            private constant real Heal_UPDATE_TIME = 0.035
        endglobals

        private struct Heal_Data
            integer abilityLevel
            Unit caster
            unit dummyUnit
            real refreshedLife
            Unit target
            real targetX
            real targetY
            real targetZ
            real x
            real y
            real z
        endstruct

        private function Heal_Ending takes Heal_Data d, unit dummyUnit, boolean isTargetNotNull, timer moveTimer, Unit target returns nothing
            local integer targetId
            call d.destroy()
            call SetUnitAnimationByIndex( dummyUnit, 2 )
            call RemoveUnitTimed( dummyUnit, 1 )
            if ( isTargetNotNull ) then
                set targetId = target.id
                call RemoveIntegerFromTableById( targetId, Heal_SCOPE_ID, d )
                if ( CountIntegersInTableById( targetId, Heal_SCOPE_ID ) == TABLE_EMPTY ) then
                    //! runtextmacro RemoveEventById( "targetId", "Heal_EVENT_DEATH" )
                endif
            endif
            call FlushAttachedInteger( moveTimer, Heal_SCOPE_ID )
            call DestroyTimerWJ( moveTimer )
        endfunction

        private function Heal_Death_ResetTarget takes Heal_Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
            local integer targetId = target.id
            set d.target = NULL
            call RemoveIntegerFromTableById( targetId, Heal_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, Heal_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "Heal_EVENT_DEATH" )
            endif
            set d.targetX = targetX
            set d.targetY = targetY
            set d.targetZ = targetZ
        endfunction

        public function Heal_Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
            local Heal_Data d
            local integer targetId = target.id
            local integer iteration = CountIntegersInTableById( targetId, Heal_SCOPE_ID )
            if (iteration > TABLE_EMPTY) then
                loop
                    set d = GetIntegerFromTableById( targetId, Heal_SCOPE_ID, iteration )
                    call Heal_Death_ResetTarget( d, target, targetX, targetY, targetZ )
                    set iteration = iteration - 1
                    exitwhen ( iteration < TABLE_STARTED )
                endloop
            endif
        endfunction

        private function Heal_Death_Event takes nothing returns nothing
            local unit dyingUnitSelf = DYING_UNIT.self
            local real dyingUnitX = GetUnitX(dyingUnitSelf)
            local real dyingUnitY = GetUnitY(dyingUnitSelf)
            call Heal_Death( DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) )
            set dyingUnitSelf = null
        endfunction

        private function Heal_TargetConditionsSingle takes unit caster, player casterOwner, unit checkingUnit returns boolean
            if ( checkingUnit == caster ) then
                return false
            endif
            if ( GetUnitState( checkingUnit, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            if ( GetUnitState( checkingUnit, UNIT_STATE_LIFE ) >= GetUnitState( checkingUnit, UNIT_STATE_MAX_LIFE ) ) then
                return false
            endif
            if ( IsUnitAlly( checkingUnit, casterOwner ) == false ) then
                return false
            endif
            if ( IsUnitType( checkingUnit, UNIT_TYPE_MECHANICAL ) ) then
                return false
            endif
            if ( IsUnitType( checkingUnit, UNIT_TYPE_STRUCTURE ) ) then
                return false
            endif
            return true
        endfunction

        private function Heal_TargetConditions takes nothing returns boolean
            return Heal_TargetConditionsSingle( TEMP_UNIT_SELF, TEMP_PLAYER, GetFilterUnit() )
        endfunction

        private function Heal_Move takes nothing returns nothing
            local real angleLengthXYZ
            local real angleXY
            local Unit caster
            local real distanceX
            local real distanceY
            local real distanceZ
            local boolean isTargetNotNull
            local real lengthXY
            local timer moveTimer = GetExpiredTimer()
            local Heal_Data d = GetAttachedInteger(moveTimer, Heal_SCOPE_ID)
            local integer abilityLevel = d.abilityLevel
            local unit dummyUnit = d.dummyUnit
            local real length = Heal_LENGTH[abilityLevel]
            local boolean reachesTarget
            local real refreshedLife
            local Unit target = d.target
            local boolean isTargetNull = ( target == NULL )
            local unit targetSelf
            local real targetX
            local real targetY
            local real targetZ
            local real x = d.x
            local real y = d.y
            local real z = d.z
            if ( isTargetNull ) then
                set targetX = d.targetX
                set targetY = d.targetY
                set targetZ = d.targetZ
            else
                set targetSelf = target.self
                set targetX = GetUnitX( targetSelf )
                set targetY = GetUnitY( targetSelf )
                set targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target)
            endif
            set reachesTarget = ( DistanceByCoordinatesWithZ( x, y, z, targetX, targetY, targetZ ) <= length )
            if ( reachesTarget ) then
                set x = targetX
                set y = targetY
                set z = targetZ
            else
                set distanceZ = targetZ - z
                set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( x, y, targetX, targetY ) )
                set distanceX = targetX - x
                set distanceY = targetY - y
                set angleXY = Atan2( distanceY, distanceX )
                set lengthXY = length * Cos( angleLengthXYZ )
                set x = x + lengthXY * Cos( angleXY )
                set y = y + lengthXY * Sin( angleXY )
                set z = z + length * Sin( angleLengthXYZ )
                call SetUnitFacingWJ( dummyUnit, angleXY )
            endif
            call SetUnitX( dummyUnit, x )
            call SetUnitY( dummyUnit, y )
            call SetUnitZ( dummyUnit, x, y, z )
            if ( reachesTarget ) then
                set caster = d.caster
                set isTargetNotNull = (isTargetNull == false)
                set refreshedLife = d.refreshedLife
                call Heal_Ending(d, dummyUnit, isTargetNotNull, moveTimer, target)
                if ( isTargetNotNull ) then
                    if ( Heal_TargetConditionsSingle( caster.self, caster.owner, targetSelf ) ) then
                        call DestroyEffectWJ( AddSpecialEffectTargetWJ( Heal_TARGET_EFFECT_PATH, targetSelf, Heal_TARGET_EFFECT_ATTACHMENT_POINT ) )
                        call HealUnitBySpell( target, refreshedLife )
                    endif
                endif
            else
                set d.x = x
                set d.y = y
                set d.z = z
            endif
            set dummyUnit = null
            set moveTimer = null
            set targetSelf = null
        endfunction

        private function Heal_Damage_Conditions takes integer abilityLevel, Unit caster, player casterOwner, Unit target returns boolean
            if ( abilityLevel <= 0 ) then
                return false
            endif
            if ( IsUnitAlly( target.self, casterOwner ) ) then
                return false
            endif
            if ( GetRandomReal( 0.01, 1 ) > Heal_CHANCE[abilityLevel] ) then
                return false
            endif
            if ( IsUnitWard( target ) ) then
                return false
            endif
            return true
        endfunction

        public function Heal_Damage takes Unit caster, real damageAmount, Unit target returns nothing
            local player casterOwner = caster.owner
            local unit casterSelf = caster.self
            local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
            local real currentLife
            local Heal_Data d
            local unit dummyUnit
            local Unit enumUnit
            local integer enumUnitId
            local unit enumUnitSelf
            local real enumUnitLife
            local real enumUnitX
            local real enumUnitY
            local boolean found
            local integer iteration
            local timer moveTimer
            local real refreshedLife
            local integer shotsAmount
            local unit targetSelf
            local real targetX
            local real targetY
            local real targetZ
            if ( Heal_Damage_Conditions( abilityLevel, caster, casterOwner, target ) ) then
                set targetSelf = target.self
                set targetX = GetUnitX( targetSelf )
                set targetY = GetUnitY( targetSelf )
                set targetSelf = null
                set TEMP_PLAYER = casterOwner
                set TEMP_UNIT_SELF = casterSelf
                call GroupEnumUnitsInRangeWithCollision( Heal_ENUM_GROUP, targetX, targetY, Heal_AREA_RANGE, Heal_TARGET_CONDITIONS )
                set enumUnitSelf = FirstOfGroup( Heal_ENUM_GROUP )
                if ( enumUnitSelf != null ) then
                    set iteration = 1
                    set refreshedLife = damageAmount * Heal_REFRESHED_LIFE_PER_DAMAGE_POINT[abilityLevel] + GetHeroStrengthTotal( caster ) * Heal_REFRESHED_LIFE_PER_DAMAGE_POINT_PER_STRENGTH_POINT[abilityLevel]
                    set shotsAmount = Heal_SHOTS_AMOUNT[abilityLevel]
                    set targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitOutpactZ(target)
                    loop
                        exitwhen ( iteration > shotsAmount )
                        set found = false
                        loop
                            call GroupRemoveUnit( Heal_ENUM_GROUP, enumUnitSelf )
                            call GroupAddUnit( Heal_ENUM_GROUP2, enumUnitSelf )
                            set enumUnitLife = GetUnitState( enumUnitSelf, UNIT_STATE_LIFE )
                            if ( found == false ) then
                                set currentLife = enumUnitLife
                                set found = true
                            elseif ( enumUnitLife < currentLife ) then
                                set currentLife = enumUnitLife
                            endif
                            set enumUnitSelf = FirstOfGroup( Heal_ENUM_GROUP )
                            exitwhen ( enumUnitSelf == null )
                        endloop
                        loop
                            set enumUnitSelf = FirstOfGroup( Heal_ENUM_GROUP2 )
                            exitwhen ( enumUnitSelf == null )
                            call GroupRemoveUnit( Heal_ENUM_GROUP2, enumUnitSelf )
                            if ( GetUnitState( enumUnitSelf, UNIT_STATE_LIFE ) == currentLife ) then
                                set d = Heal_Data.create()
                                set enumUnit = GetUnit(enumUnitSelf)
                                set enumUnitId = enumUnit.id
                                set enumUnitX = GetUnitX( enumUnitSelf )
                                set enumUnitY = GetUnitY( enumUnitSelf )
                                set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, Heal_DUMMY_UNIT_ID, targetX, targetY, Atan2( enumUnitY - targetY, enumUnitX - targetX ) )
                                set moveTimer = CreateTimerWJ()
                                set d.abilityLevel = abilityLevel
                                set d.caster = caster
                                set d.dummyUnit = dummyUnit
                                set d.refreshedLife = refreshedLife
                                set d.target = enumUnit
                                set d.x = targetX
                                set d.y = targetY
                                set d.z = targetZ
                                call AddIntegerToTableById( enumUnitId, Heal_SCOPE_ID, d )
                                if ( CountIntegersInTableById( enumUnitId, Heal_SCOPE_ID ) == TABLE_STARTED ) then
                                    //! runtextmacro AddEventById( "enumUnitId", "Heal_EVENT_DEATH" )
                                endif
                                call AttachInteger( moveTimer, Heal_SCOPE_ID, d )
                                call SetUnitZ(dummyUnit, targetX, targetY, targetZ)
                                call TimerStart( moveTimer, Heal_UPDATE_TIME, true, function Heal_Move )
                                set iteration = iteration + 1
                            else
                                call GroupAddUnit( Heal_ENUM_GROUP, enumUnitSelf )
                            endif
                        endloop
                        set enumUnitSelf = FirstOfGroup( Heal_ENUM_GROUP )
                        exitwhen ( enumUnitSelf == null )
                    endloop
                    set dummyUnit = null
                    set moveTimer = null
                endif
            endif
            set casterSelf = null
        endfunction

        private function Heal_Damage_Event takes nothing returns nothing
            call Heal_Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
        endfunction

        public function Heal_Learn takes Unit caster returns nothing
            local integer casterId = caster.id
            local Heal_Data d = GetAttachedIntegerById(casterId, Heal_SCOPE_ID)
            if ( d == NULL ) then
                set d = Heal_Data.create()
                set d.abilityLevel = GetUnitAbilityLevel(caster.self, SPELL_ID)
                call AttachIntegerById(casterId, Heal_SCOPE_ID, d)
                //! runtextmacro AddEventById( "casterId", "Heal_EVENT_DAMAGE" )
            endif
        endfunction

        private function Heal_Learn_Event takes nothing returns nothing
            call Heal_Learn( LEARNER )
        endfunction

        public function Heal_Init takes nothing returns nothing
            local integer iteration = LEVELS_AMOUNT
            set Heal_CHANCE[1] = 0.3
            set Heal_CHANCE[2] = 0.35
            set Heal_CHANCE[3] = 0.4
            set Heal_CHANCE[4] = 0.45
            set Heal_CHANCE[5] = 0.5
            set Heal_ENUM_GROUP = CreateGroupWJ()
            set Heal_ENUM_GROUP2 = CreateGroupWJ()
            //! runtextmacro CreateEvent( "Heal_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Heal_Damage_Event" )
            //! runtextmacro CreateEvent( "Heal_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Heal_Death_Event" )
            set Heal_SHOTS_AMOUNT[1] = 3
            set Heal_SHOTS_AMOUNT[2] = 3
            set Heal_SHOTS_AMOUNT[3] = 3
            set Heal_SHOTS_AMOUNT[4] = 3
            set Heal_SHOTS_AMOUNT[5] = 3
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT[1] = 0.6
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT[2] = 0.75
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT[3] = 0.9
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT[4] = 1.05
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT[5] = 1.2
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT_PER_STRENGTH_POINT[1] = 0.005
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT_PER_STRENGTH_POINT[2] = 0.005
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT_PER_STRENGTH_POINT[3] = 0.005
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT_PER_STRENGTH_POINT[4] = 0.005
            set Heal_REFRESHED_LIFE_PER_DAMAGE_POINT_PER_STRENGTH_POINT[5] = 0.005
            set Heal_SPEED[1] = 800
            set Heal_SPEED[2] = 800
            set Heal_SPEED[3] = 800
            set Heal_SPEED[4] = 1000
            set Heal_SPEED[5] = 1000
            loop
                set Heal_LENGTH[iteration] = Heal_SPEED[iteration] * Heal_UPDATE_TIME
                set iteration = iteration - 1
                exitwhen (iteration < 1)
            endloop
            set Heal_TARGET_CONDITIONS = ConditionWJ( function Heal_TargetConditions )
            call InitUnitType( Heal_DUMMY_UNIT_ID )
            call InitEffectType( Heal_TARGET_EFFECT_PATH )
            //! runtextmacro AddNewEventById( "Heal_EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Heal_Learn_Event" )
        endfunction
    //! runtextmacro Endscope()

    //! runtextmacro Scope("Aura")
        globals
            private real array Aura_AREA_RANGE
            private real array Aura_BONUS_DAMAGE_RELATIVE
            private group Aura_ENUM_GROUP
            private group Aura_ENUM_GROUP2
            private boolexpr Aura_TARGET_CONDITIONS
            private constant real Aura_UPDATE_TIME = 1
        endglobals

        private struct Aura_Data
            integer abilityLevel
            Unit caster
            group targetGroup
            timer updateTimer
        endstruct

        //! runtextmacro Scope("Target")
            private struct Target_Data
                Aura_Data d
            endstruct

            private function Target_Ending takes real bonusDamage, Unit caster, Target_Data d, Unit target, group targetGroup returns nothing
                local integer targetId = target.id
                call d.destroy()
                call GroupRemoveUnit( targetGroup, target.self )
                call RemoveIntegerFromTableById( targetId, Target_SCOPE_ID, d )
                if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_EMPTY ) then
                    //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                endif
                call AddUnitDamageBonus( caster, bonusDamage )
            endfunction

            public function Target_EndingByEnding takes real bonusDamage, Unit caster, Aura_Data d, Unit target, group targetGroup returns nothing
                local Target_Data e
                local integer targetId = target.id
                local integer iteration = CountIntegersInTableById(targetId, Target_SCOPE_ID)
                loop
                    set e = GetIntegerFromTableById(targetId, Target_SCOPE_ID, iteration)
                    exitwhen (e.d == d)
                    set iteration = iteration - 1
                endloop
                call Target_Ending(bonusDamage, caster, e, target, targetGroup)
            endfunction

            public function Target_Death takes Unit target returns nothing
                local Unit caster
                local Aura_Data d
                local Target_Data e
                local integer targetId = target.id
                local integer iteration = CountIntegersInTableById( targetId, Target_SCOPE_ID )
                if (iteration > TABLE_EMPTY) then
                    loop
                        set e = GetIntegerFromTableById( targetId, Target_SCOPE_ID, iteration )
                        set d = e.d
                        set caster = d.caster
                        call Target_Ending( -Aura_BONUS_DAMAGE_RELATIVE[d.abilityLevel] * GetUnitDamage( caster ), caster, e, target, d.targetGroup )
                        set iteration = iteration - 1
                        exitwhen ( iteration < TABLE_STARTED )
                    endloop
                endif
            endfunction

            private function Target_Death_Event takes nothing returns nothing
                call Target_Death( DYING_UNIT )
            endfunction

            public function Target_Start takes Aura_Data d, Unit target returns nothing
                local Target_Data e = Target_Data.create()
                local integer targetId = target.id
                set e.d = d
                call AddIntegerToTableById( targetId, Target_SCOPE_ID, e )
                if ( CountIntegersInTableById( targetId, Target_SCOPE_ID ) == TABLE_STARTED ) then
                    //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
                endif
            endfunction

            public function Target_Init takes nothing returns nothing
                //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            endfunction
        //! runtextmacro Endscope()

        public function Aura_Death takes Unit caster returns nothing
            local real bonusDamage
            local Aura_Data d = GetAttachedIntegerById(caster.id, Aura_SCOPE_ID)
            local unit enumUnit
            local group targetGroup
            if ( d != NULL ) then
                set bonusDamage = -Aura_BONUS_DAMAGE_RELATIVE[d.abilityLevel] * GetUnitDamage( caster )
                set targetGroup = d.targetGroup
                loop
                    set enumUnit = FirstOfGroup( targetGroup )
                    exitwhen ( enumUnit == null )
                    call Target_Target_EndingByEnding( bonusDamage, caster, d, GetUnit(enumUnit), targetGroup )
                endloop
                set targetGroup = null
                call PauseTimer( d.updateTimer )
            endif
        endfunction

        private function Aura_Death_Event takes nothing returns nothing
            call Aura_Death( DYING_UNIT )
        endfunction

        private function Aura_TargetConditions takes nothing returns boolean
            set FILTER_UNIT_SELF = GetFilterUnit()
            if (FILTER_UNIT_SELF == TEMP_UNIT_SELF) then
                return false
            endif
            if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
                return false
            endif
            if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
                return false
            endif
            if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
                return false
            endif
            if ( IsUnitWard( GetUnit(FILTER_UNIT_SELF) ) ) then
                return false
            endif
            return true
        endfunction

        private function Aura_Update takes integer abilityLevel, Unit caster, Aura_Data d, group targetGroup returns nothing
            local real areaRange = Aura_AREA_RANGE[abilityLevel]
            local real bonusDamage = Aura_BONUS_DAMAGE_RELATIVE[abilityLevel] * GetUnitDamage( caster )
            local unit casterSelf = caster.self
            local real casterX = GetUnitX( casterSelf )
            local real casterY = GetUnitY( casterSelf )
            local unit enumUnit
            local real enumUnitX
            local real enumUnitY
            set TEMP_PLAYER = caster.owner
            set TEMP_UNIT_SELF = casterSelf
            set casterSelf = null
            call GroupEnumUnitsInRangeWithCollision( Aura_ENUM_GROUP, casterX, casterY, areaRange, Aura_TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup( targetGroup )
            if ( enumUnit != null ) then
                loop
                    if ( IsUnitInGroup( enumUnit, Aura_ENUM_GROUP ) ) then
                        call GroupRemoveUnit( Aura_ENUM_GROUP, enumUnit )
                        call GroupRemoveUnit( targetGroup, enumUnit )
                        call GroupAddUnit( Aura_ENUM_GROUP2, enumUnit )
                    else
                        call Target_Target_EndingByEnding( -bonusDamage, caster, d, GetUnit(enumUnit), targetGroup )
                    endif
                    set enumUnit = FirstOfGroup( targetGroup )
                    exitwhen ( enumUnit == null )
                endloop
                set enumUnit = FirstOfGroup( Aura_ENUM_GROUP2 )
                loop
                    call GroupRemoveUnit( Aura_ENUM_GROUP2, enumUnit )
                    call GroupAddUnit( targetGroup, enumUnit )
                    set enumUnit = FirstOfGroup( Aura_ENUM_GROUP2 )
                    exitwhen ( enumUnit == null )
                endloop
            endif
            loop
                set enumUnit = FirstOfGroup( Aura_ENUM_GROUP )
                exitwhen ( enumUnit == null )
                call GroupRemoveUnit( Aura_ENUM_GROUP, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                call Target_Target_Start(d, GetUnit(enumUnit))
                call AddUnitDamageBonus( caster, bonusDamage )
            endloop
        endfunction

        private function Aura_UpdateByTimer takes nothing returns nothing
            local timer updateTimer = GetExpiredTimer()
            local Aura_Data d = GetAttachedInteger(updateTimer, Aura_SCOPE_ID)
            call Aura_Update( d.abilityLevel, d.caster, d, d.targetGroup )
            set updateTimer = null
        endfunction

        public function Aura_LevelGain_Before takes Unit caster returns nothing
            local real bonusDamage
            local Aura_Data d = GetAttachedIntegerById(caster.id, Aura_SCOPE_ID)
            local unit enumUnit
            local group targetGroup
            if ( d != NULL ) then
                set bonusDamage = -Aura_BONUS_DAMAGE_RELATIVE[d.abilityLevel] * GetUnitDamage( caster )
                set targetGroup = d.targetGroup
                set enumUnit = FirstOfGroup( targetGroup )
                if (enumUnit != null) then
                    loop
                        call Target_Target_EndingByEnding( bonusDamage, caster, d, GetUnit(enumUnit), targetGroup )
                        set enumUnit = FirstOfGroup( targetGroup )
                        exitwhen ( enumUnit == null )
                    endloop
                endif
                call Aura_Update(d.abilityLevel, caster, d, targetGroup)
                set targetGroup = null
            endif
        endfunction

        public function Aura_Revive takes Unit caster returns nothing
            local Aura_Data d = GetAttachedIntegerById(caster.id, Aura_SCOPE_ID)
            local timer updateTimer
            if ( d != NULL ) then
                set updateTimer = d.updateTimer
                call TimerStart( updateTimer, Aura_UPDATE_TIME, true, function Aura_UpdateByTimer )
                set updateTimer = null
                call Aura_Update( d.abilityLevel, caster, d, d.targetGroup )
            endif
        endfunction

        private function Aura_Revive_Event takes nothing returns nothing
            call Aura_Revive( REVIVING_UNIT )
        endfunction

        public function Aura_Learn takes Unit caster returns nothing
            local integer abilityLevel = GetUnitAbilityLevel(caster.self, SPELL_ID)
            local real bonusDamage
            local unit enumUnit
            local real newBonusDamage
            local real oldBonusDamage
            local group targetGroup
            local integer casterId = caster.id
            local Aura_Data d = GetAttachedIntegerById(casterId, Aura_SCOPE_ID)
            local boolean isNew = ( d == NULL )
            local timer updateTimer
            if ( isNew ) then
                set d = Aura_Data.create()
                set updateTimer = CreateTimerWJ()
                set d.caster = caster
                set d.targetGroup = CreateGroupWJ()
                set d.updateTimer = updateTimer
                call AttachIntegerById(casterId, Aura_SCOPE_ID, d)
                //! runtextmacro AddEventById( "casterId", "Aura_EVENT_DEATH" )
                //! runtextmacro AddEventById( "casterId", "Aura_EVENT_REVIVE" )
                call AttachInteger(updateTimer, Aura_SCOPE_ID, d)
            else
                set targetGroup = d.targetGroup
            endif
            set d.abilityLevel = abilityLevel
            if ( isNew ) then
                call TimerStart( updateTimer, Aura_UPDATE_TIME, true, function Aura_UpdateByTimer )
                set updateTimer = null
            else
                set targetGroup = d.targetGroup
                set enumUnit = FirstOfGroup( targetGroup )
                if ( enumUnit != null ) then
                    set bonusDamage = -Aura_BONUS_DAMAGE_RELATIVE[d.abilityLevel] * GetUnitDamage( caster )
                    loop
                        call Target_Target_EndingByEnding(bonusDamage, caster, d, GetUnit(enumUnit), targetGroup)
                        set enumUnit = FirstOfGroup( targetGroup )
                        exitwhen (enumUnit == null)
                    endloop
                endif
            endif
            call Aura_Update( abilityLevel, caster, d, targetGroup )
            set targetGroup = null
        endfunction

        private function Aura_Learn_Event takes nothing returns nothing
            call Aura_Learn( LEARNER )
        endfunction

        public function Aura_Init takes nothing returns nothing
            set Aura_AREA_RANGE[1] = 500
            set Aura_AREA_RANGE[2] = 500
            set Aura_AREA_RANGE[3] = 500
            set Aura_AREA_RANGE[4] = 500
            set Aura_AREA_RANGE[5] = 500
            set Aura_BONUS_DAMAGE_RELATIVE[1] = 0.02
            set Aura_BONUS_DAMAGE_RELATIVE[2] = 0.02
            set Aura_BONUS_DAMAGE_RELATIVE[3] = 0.02
            set Aura_BONUS_DAMAGE_RELATIVE[4] = 0.02
            set Aura_BONUS_DAMAGE_RELATIVE[5] = 0.02
            set Aura_ENUM_GROUP = CreateGroupWJ()
            set Aura_ENUM_GROUP2 = CreateGroupWJ()
            //! runtextmacro CreateEvent( "Aura_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Aura_Death_Event" )
            //! runtextmacro CreateEvent( "Aura_EVENT_REVIVE", "UnitFinishesReviving_EVENT_KEY", "0", "function Aura_Revive_Event" )
            set Aura_TARGET_CONDITIONS = ConditionWJ( function Aura_TargetConditions )
            //! runtextmacro AddNewEventById( "Aura_EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Aura_Learn_Event" )
            call Target_Target_Init()
        endfunction
    //! runtextmacro Endscope()

    public function Init takes nothing returns nothing
        call InitAbility( SPELL_ID )
        call Aura_Aura_Init()
        call Heal_Heal_Init()
    endfunction
//! runtextmacro Endscope()