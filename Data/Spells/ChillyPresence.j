//TESH.scrollpos=349
//TESH.alwaysfold=0
//! runtextmacro Scope("ChillyPresence")
    globals
        public constant integer SPELL_ID = 'A006'

        private real array AREA_RANGE
        private real array AREA_RANGE_PER_AGILITY_POINT
        private real array BONUS_MANA_REGENERATION_RELATIVE
        private real array BONUS_SPEED_RELATIVE
        private group ENUM_GROUP
        private group ENUM_GROUP2
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Other\\Drain\\ManaDrainCaster.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 1.
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        effect casterEffect
        group targetGroup
        timer updateTimer
    endstruct

    private function GetCasterData takes Unit caster returns Data
        return GetAttachedIntegerById(caster.id, ChillyPresence_SCOPE_ID)
    endfunction

    //! runtextmacro Scope("Target")
        globals
            private group Target_ENUM_GROUP
            private constant string Target_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\GeneralAuraTarget\\GeneralAuraTarget.mdl"
            private constant string Target_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Target_Data
            real bonusManaRegeneration
            real bonusSpeed
            group casterGroup
            Data d
            effect targetEffect
        endstruct

        private function Target_Ending takes Unit caster, group casterGroup, Data d, Target_Data e, integer oldAbilityLevel, Unit target, group targetGroup returns nothing
            local real bonusManaRegeneration
            local real bonusSpeed
            local Unit enumUnit
            local unit enumUnitSelf
            local integer enumUnitAbilityLevel
            local integer iteration
            local integer newLevel
            local real oldBonusManaRegeneration
            local real oldBonusSpeed
            local effect targetEffect
            local integer targetId
            call GroupRemoveUnit( casterGroup, caster.self )
            call GroupRemoveUnit( targetGroup, target.self )
            if (e.d == d) then
                set iteration = oldAbilityLevel - 1
                set oldBonusManaRegeneration = e.bonusManaRegeneration
                set oldBonusSpeed = e.bonusSpeed
                set enumUnitSelf = FirstOfGroup(casterGroup)
                if (enumUnitSelf == null) then
                    set targetEffect = e.targetEffect
                    set targetId = target.id
                    call e.destroy()
                    call DestroyGroupWJ(casterGroup)
                    call FlushAttachedIntegerById( targetId, Target_SCOPE_ID )
                    //! runtextmacro RemoveEventById( "targetId", "Target_EVENT_DEATH" )
                    call DestroyEffectWJ( targetEffect )
                    set targetEffect = null
                    call AddUnitManaRegenerationBonus( target, -oldBonusManaRegeneration )
                    call AddUnitSpeedBonus( target, -oldBonusSpeed )
                else
                    set newLevel = 0
                    loop
                        set enumUnit = GetUnit(enumUnitSelf)
                        set enumUnitAbilityLevel = GetCasterData(enumUnit).abilityLevel
                        call GroupRemoveUnit(casterGroup, enumUnitSelf)
                        if (enumUnitAbilityLevel > newLevel) then
                            set caster = enumUnit
                            set newLevel = enumUnitAbilityLevel
                        endif
                        call GroupAddUnit(Target_ENUM_GROUP, enumUnitSelf)
                        set enumUnitSelf = FirstOfGroup(casterGroup)
                        exitwhen (enumUnitSelf == null)
                    endloop
                    set enumUnitSelf = FirstOfGroup(Target_ENUM_GROUP)
                    loop
                        call GroupRemoveUnit(Target_ENUM_GROUP, enumUnitSelf)
                        call GroupAddUnit(casterGroup, enumUnitSelf)
                        set enumUnitSelf = FirstOfGroup(Target_ENUM_GROUP)
                        exitwhen (enumUnitSelf == null)
                    endloop
                    set bonusManaRegeneration = GetUnitManaRegeneration( target ) * BONUS_MANA_REGENERATION_RELATIVE[newLevel]
                    set bonusSpeed = GetUnitSpeedTotal( target ) * BONUS_SPEED_RELATIVE[newLevel]
                    set e.bonusManaRegeneration = bonusManaRegeneration
                    set e.bonusSpeed = bonusSpeed
                    set e.d = GetCasterData(caster)
                    call AddUnitManaRegenerationBonus( target, bonusManaRegeneration - oldBonusManaRegeneration )
                    call AddUnitSpeedBonus( target, bonusSpeed - oldBonusSpeed )
                endif
            endif
        endfunction

        public function Target_EndingByEnding takes integer abilityLevel, Unit caster, Data d, Unit target, group targetGroup returns nothing
            local Target_Data e = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            call Target_Ending(caster, e.casterGroup, d, e, abilityLevel, target, targetGroup)
        endfunction

        public function Target_Death takes Unit target returns nothing
            local integer abilityLevel
            local Data d
            local Target_Data e = GetAttachedIntegerById(target.id, Target_SCOPE_ID)
            local group casterGroup = e.casterGroup
            local integer iteration
            if (e != NULL) then
                set iteration = CountUnits(casterGroup)
                loop
                    set d = e.d
                    set abilityLevel = d.abilityLevel
                    call Target_Ending( GetUnit(FirstOfGroup(casterGroup)), casterGroup, d, e, abilityLevel, target, d.targetGroup )
                    set iteration = iteration - 1
                    exitwhen (iteration < 1)
                endloop
            endif
            set casterGroup = null
        endfunction

        private function Target_Death_Event takes nothing returns nothing
            call Target_Death( DYING_UNIT )
        endfunction

        public function Target_Start takes integer abilityLevel, real bonusManaRegenerationRelative, real bonusSpeedRelative, Unit caster, Data d, Unit target returns nothing
            local real bonusManaRegeneration = GetUnitManaRegeneration( target ) * bonusManaRegenerationRelative
            local real bonusSpeed = GetUnitSpeedTotal( target ) * bonusSpeedRelative
            local group casterGroup
            local integer oldAbilityLevel
            local real oldBonusManaRegeneration
            local real oldBonusSpeed
            local integer targetId = target.id
            local Target_Data e = GetAttachedIntegerById(targetId, Target_SCOPE_ID)
            local boolean isNew = (e == NULL)
            if (isNew) then
                set casterGroup = CreateGroupWJ()
                set e = Target_Data.create()
                set e.casterGroup = casterGroup
                set e.d = d
                set e.targetEffect = AddSpecialEffectTargetWJ( Target_TARGET_EFFECT_PATH, target.self, Target_TARGET_EFFECT_ATTACHMENT_POINT )
                call AttachIntegerById(targetId, Target_SCOPE_ID, e)
                //! runtextmacro AddEventById( "targetId", "Target_EVENT_DEATH" )
            else
                set casterGroup = e.casterGroup
                set oldAbilityLevel = e.d.abilityLevel
                set oldBonusManaRegeneration = e.bonusManaRegeneration
                set oldBonusSpeed = e.bonusSpeed
            endif
            set e.bonusManaRegeneration = bonusManaRegeneration
            set e.bonusSpeed = bonusSpeed
            call GroupAddUnit(casterGroup, caster.self)
            set casterGroup = null
            if (isNew) then
                call AddUnitManaRegenerationBonus( target, bonusManaRegeneration )
                call AddUnitSpeedBonus( target, bonusSpeed )
            elseif (abilityLevel >= oldAbilityLevel) then
                set e.d = d
                call AddUnitManaRegenerationBonus( target, bonusManaRegeneration - oldBonusManaRegeneration )
                call AddUnitSpeedBonus( target, bonusSpeed - oldBonusSpeed )
            endif
        endfunction

        public function Target_Init takes nothing returns nothing
            set Target_ENUM_GROUP = CreateGroupWJ()
            //! runtextmacro CreateEvent( "Target_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Target_Death_Event" )
            call InitEffectType( Target_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    public function Death takes Unit caster returns nothing
        local integer abilityLevel
        local unit enumUnit
        local group targetGroup
        local Data d = GetAttachedIntegerById( caster.id, ChillyPresence_SCOPE_ID )
        if ( d != NULL ) then
            set abilityLevel = d.abilityLevel
            set targetGroup = d.targetGroup
            loop
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
                call Target_Target_EndingByEnding( abilityLevel, caster, d, GetUnit(enumUnit), targetGroup )
            endloop
            set targetGroup = null
            call PauseTimer( d.updateTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Update takes integer abilityLevel, Unit caster, Data d, group targetGroup returns nothing
        local real bonusManaRegenerationRelative
        local real bonusSpeedRelative
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local unit enumUnit
        local real enumUnitX
        local real enumUnitY
        set casterSelf = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE[abilityLevel] + GetHeroAgilityTotal( caster ) * AREA_RANGE_PER_AGILITY_POINT[abilityLevel], TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( targetGroup )
        if ( enumUnit != null ) then
            loop
                if ( IsUnitInGroup( enumUnit, ENUM_GROUP ) == false ) then
                    call Target_Target_EndingByEnding( abilityLevel, caster, d, GetUnit(enumUnit), targetGroup )
                else
                    call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                    call GroupRemoveUnit( targetGroup, enumUnit )
                    call GroupAddUnit( ENUM_GROUP2, enumUnit )
                endif
                set enumUnit = FirstOfGroup( targetGroup )
                exitwhen ( enumUnit == null )
            endloop
            set enumUnit = FirstOfGroup( ENUM_GROUP2 )
            loop
                call GroupRemoveUnit( ENUM_GROUP2, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                set enumUnit = FirstOfGroup( ENUM_GROUP2 )
                exitwhen ( enumUnit == null )
            endloop
        endif
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            set bonusManaRegenerationRelative = BONUS_MANA_REGENERATION_RELATIVE[abilityLevel]
            set bonusSpeedRelative = BONUS_SPEED_RELATIVE[abilityLevel]
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call GroupAddUnit( targetGroup, enumUnit )
                call Target_Target_Start(abilityLevel, bonusManaRegenerationRelative, bonusSpeedRelative, caster, d, GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function UpdateByTimer takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, ChillyPresence_SCOPE_ID)
        set updateTimer = null
        call Update( d.abilityLevel, d.caster, d, d.targetGroup )
    endfunction

    public function Revive takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, ChillyPresence_SCOPE_ID)
        if ( d != NULL ) then
            call TimerStart( d.updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            call Update( d.abilityLevel, caster, d, d.targetGroup )
        endif
    endfunction

    private function Revive_Event takes nothing returns nothing
        call Revive( REVIVING_UNIT )
    endfunction

    public function Learn takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel(casterSelf, SPELL_ID)
        local Data d = GetAttachedIntegerById(casterId, ChillyPresence_SCOPE_ID)
        local unit enumUnit
        local boolean isNew = ( d == NULL )
        local real lastBonusSpeed
        local group targetGroup
        local timer updateTimer
        if ( isNew ) then
            set d = Data.create()
            set targetGroup = CreateGroupWJ()
            set updateTimer = CreateTimerWJ()
            set d.caster = caster
            set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
            set d.targetGroup = targetGroup
            set d.updateTimer = updateTimer
            call AttachIntegerById( casterId, ChillyPresence_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_REVIVE" )
            call AttachInteger( updateTimer, ChillyPresence_SCOPE_ID, d )
        else
            set targetGroup = d.targetGroup
        endif
        set casterSelf = null
        set d.abilityLevel = abilityLevel
        if ( isNew ) then
            call TimerStart( updateTimer, UPDATE_TIME, true, function UpdateByTimer )
            set updateTimer = null
        else
            set enumUnit = FirstOfGroup( targetGroup )
            if ( enumUnit != null ) then
                loop
                    call GroupRemoveUnit( targetGroup, enumUnit )
                    call Target_Target_EndingByEnding(abilityLevel, caster, d, GetUnit(enumUnit), targetGroup)
                    set enumUnit = FirstOfGroup( targetGroup )
                    exitwhen ( enumUnit == null )
                endloop
            endif
        endif
        call Update( abilityLevel, caster, d, targetGroup )
        set targetGroup = null
    endfunction

    private function Learn_Event takes nothing returns nothing
        call Learn( LEARNER )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 500
        set AREA_RANGE[2] = 500
        set AREA_RANGE[3] = 500
        set AREA_RANGE[4] = 500
        set AREA_RANGE[5] = 500
        set AREA_RANGE_PER_AGILITY_POINT[1] = 6
        set AREA_RANGE_PER_AGILITY_POINT[2] = 6
        set AREA_RANGE_PER_AGILITY_POINT[3] = 6
        set AREA_RANGE_PER_AGILITY_POINT[4] = 6
        set AREA_RANGE_PER_AGILITY_POINT[5] = 6
        set BONUS_MANA_REGENERATION_RELATIVE[1] = -0.3
        set BONUS_MANA_REGENERATION_RELATIVE[2] = -0.35
        set BONUS_MANA_REGENERATION_RELATIVE[3] = -0.4
        set BONUS_MANA_REGENERATION_RELATIVE[4] = -0.45
        set BONUS_MANA_REGENERATION_RELATIVE[5] = -0.5
        set BONUS_SPEED_RELATIVE[1] = -0.15
        set BONUS_SPEED_RELATIVE[2] = -0.19
        set BONUS_SPEED_RELATIVE[3] = -0.23
        set BONUS_SPEED_RELATIVE[4] = -0.27
        set BONUS_SPEED_RELATIVE[5] = -0.31
        set ENUM_GROUP = CreateGroupWJ()
        set ENUM_GROUP2 = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_REVIVE", "UnitFinishesReviving_EVENT_KEY", "0", "function Revive_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_LEARN", "SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Learn_Event" )
        call Target_Target_Init()
    endfunction
//! runtextmacro Endscope()