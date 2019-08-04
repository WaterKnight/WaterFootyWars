//TESH.scrollpos=230
//TESH.alwaysfold=0
//! runtextmacro Scope("Stability")
    globals
        private constant integer ORDER_ID = 852604//OrderId( "submerge" )
        public constant integer SPELL_ID = 'A00B'

        private constant real AREA_RANGE = 400.
        private real array BONUS_ARMOR
        private real array BONUS_ARMOR_PER_AGILITY_POINT
        private real array BONUS_ARMOR_BY_SPELL
        private real array BONUS_ARMOR_BY_SPELL_PER_AGILITY_POINT
        private real array DURATION
        private group ENUM_GROUP
        private constant integer LEVELS_AMOUNT = 5
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Items\\AIda\\AIdaCaster.mdl"
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIda\\AIdaTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
    endglobals

    private struct Data
        integer abilityLevel
        real array bonusArmor[LEVELS_AMOUNT]
        real array bonusArmorBySpell[LEVELS_AMOUNT]
        timer array durationTimer[LEVELS_AMOUNT]
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer abilityLevel = d.abilityLevel
        local real bonusArmor
        local real bonusArmorBySpell
        local integer iteration = abilityLevel - 1
        local effect targetEffect
        local integer targetId
        loop
            exitwhen (durationTimer == d.durationTimer[iteration])
            set iteration = iteration - 1
        endloop
        set d.durationTimer[iteration] = null
        if ( abilityLevel - 1 <= iteration ) then
            set bonusArmor = d.bonusArmor[abilityLevel - 1]
            set bonusArmorBySpell = d.bonusArmorBySpell[abilityLevel - 1]
            loop
                exitwhen (iteration < 0)
                exitwhen (d.durationTimer[iteration] != null)
                set iteration = iteration - 1
            endloop
            if ( iteration > -1 ) then
                set d.abilityLevel = iteration + 1
                call AddUnitArmorBonus( target, d.bonusArmor[iteration] - bonusArmor )
                call AddUnitArmorBySpellBonus( target, d.bonusArmorBySpell[iteration] - bonusArmorBySpell )
            else
                set targetEffect = d.targetEffect
                set targetId = target.id
                call d.destroy()
                call FlushAttachedIntegerById( targetId, Stability_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
                call AddUnitArmorBonus( target, -bonusArmor )
                call AddUnitArmorBySpellBonus( target, -bonusArmorBySpell )
            endif
        endif
        call FlushAttachedInteger( durationTimer, Stability_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
    endfunction

    public function Dispel takes Unit target returns nothing
        local integer abilityLevel
        local Data d = GetAttachedIntegerById(target.id, Stability_SCOPE_ID)
        local timer durationTimer
        local integer iteration
        if (d != NULL) then
            set abilityLevel = d.abilityLevel
            set iteration = 0
            loop
                set durationTimer = d.durationTimer[iteration]
                if ( durationTimer != null ) then
                    call Ending( d, durationTimer, target )
                endif
                set iteration = iteration + 1
                exitwhen ( iteration >= abilityLevel )
            endloop
            set durationTimer = null
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, Stability_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_HERO ) ) then
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

    public function SpellEffect takes Unit caster returns nothing
        local real casterAgility = GetHeroAgilityTotal( caster )
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real bonusArmor = BONUS_ARMOR[abilityLevel] + casterAgility * BONUS_ARMOR_PER_AGILITY_POINT[abilityLevel]
        local real bonusArmorBySpell = BONUS_ARMOR_BY_SPELL[abilityLevel] + casterAgility * BONUS_ARMOR_BY_SPELL_PER_AGILITY_POINT[abilityLevel]
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d
        local real duration
        local timer durationTimer
        local Unit enumUnit
        local integer enumUnitId
        local unit enumUnitSelf
        local boolean isNew
        local integer iteration
        local integer oldAbilityLevel
        local real oldBonusArmor
        local real oldBonusArmorBySpell
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, casterX, casterY ) )
        call PlaySoundFromTypeAtPosition( STABILITY_SOUND_TYPE, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        set casterSelf = null
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, casterX, casterY, AREA_RANGE, TARGET_CONDITIONS )
        set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
        if (enumUnitSelf != null) then
            set duration = DURATION[abilityLevel]
            loop
                set enumUnit = GetUnit(enumUnitSelf)
                set enumUnitId = enumUnit.id
                set d = GetAttachedIntegerById(enumUnitId, Stability_SCOPE_ID)
                set isNew = (d == NULL)
                call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                if ( isNew ) then
                    set d = Data.create()
                    set durationTimer = CreateTimerWJ()
                    set iteration = LEVELS_AMOUNT - 1
                    set d.abilityLevel = abilityLevel
                    set d.target = enumUnit
                    loop
                        if (iteration == abilityLevel - 1) then
                            set d.durationTimer[iteration] = durationTimer
                        else
                            set d.durationTimer[iteration] = null
                        endif
                        set iteration = iteration - 1
                        exitwhen (iteration < 0)
                    endloop
                    call AttachInteger(durationTimer, Stability_SCOPE_ID, d)
                    call AttachIntegerById(enumUnitId, Stability_SCOPE_ID, d)
                    //! runtextmacro AddEventById( "enumUnitId", "EVENT_DEATH" )
                    //! runtextmacro AddEventById( "enumUnitId", "EVENT_DISPEL" )
                else
                    set durationTimer = d.durationTimer[abilityLevel - 1]
                    if (durationTimer == null) then
                        set durationTimer = CreateTimerWJ()
                        set d.durationTimer[abilityLevel - 1] = durationTimer
                        call AttachInteger(durationTimer, Stability_SCOPE_ID, d)
                    endif
                    set oldAbilityLevel = d.abilityLevel
                    set oldBonusArmor = d.bonusArmor[abilityLevel - 1]
                    set oldBonusArmorBySpell = d.bonusArmorBySpell[abilityLevel - 1]
                    call DestroyEffectWJ( d.targetEffect )
                endif
                set d.bonusArmor[abilityLevel - 1] = bonusArmor
                set d.bonusArmorBySpell[abilityLevel - 1] = bonusArmorBySpell
                set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, enumUnitSelf, TARGET_EFFECT_ATTACHMENT_POINT )
                if ( isNew ) then
                    call AddUnitArmorBonus( enumUnit, bonusArmor )
                    call AddUnitArmorBySpellBonus( enumUnit, bonusArmorBySpell )
                elseif (abilityLevel > oldAbilityLevel) then
                    set d.abilityLevel = abilityLevel
                    call AddUnitArmorBonus( enumUnit, bonusArmor - oldBonusArmor )
                    call AddUnitArmorBySpellBonus( enumUnit, bonusArmorBySpell - oldBonusArmorBySpell )
                endif
                call TimerStart( durationTimer, duration, false, function EndingByTimer )
                set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                exitwhen (enumUnitSelf == null)
            endloop
            set durationTimer = null
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        set BONUS_ARMOR[1] = 3
        set BONUS_ARMOR[2] = 5
        set BONUS_ARMOR[3] = 7
        set BONUS_ARMOR[4] = 9
        set BONUS_ARMOR[5] = 11
        set BONUS_ARMOR_PER_AGILITY_POINT[1] = 0.1
        set BONUS_ARMOR_PER_AGILITY_POINT[2] = 0.1
        set BONUS_ARMOR_PER_AGILITY_POINT[3] = 0.1
        set BONUS_ARMOR_PER_AGILITY_POINT[4] = 0.1
        set BONUS_ARMOR_PER_AGILITY_POINT[5] = 0.1
        set BONUS_ARMOR_BY_SPELL[1] = -0.25
        set BONUS_ARMOR_BY_SPELL[2] = -0.25
        set BONUS_ARMOR_BY_SPELL[3] = -0.25
        set BONUS_ARMOR_BY_SPELL[4] = -0.25
        set BONUS_ARMOR_BY_SPELL[5] = -0.25
        set BONUS_ARMOR_BY_SPELL_PER_AGILITY_POINT[1] = -0.0033
        set BONUS_ARMOR_BY_SPELL_PER_AGILITY_POINT[2] = -0.0033
        set BONUS_ARMOR_BY_SPELL_PER_AGILITY_POINT[3] = -0.0033
        set BONUS_ARMOR_BY_SPELL_PER_AGILITY_POINT[4] = -0.0033
        set BONUS_ARMOR_BY_SPELL_PER_AGILITY_POINT[5] = -0.0033
        set DURATION[1] = 16
        set DURATION[2] = 16
        set DURATION[3] = 16
        set DURATION[4] = 16
        set DURATION[5] = 16
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()