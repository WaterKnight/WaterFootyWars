//TESH.scrollpos=250
//TESH.alwaysfold=0
//! runtextmacro Scope("CurseOfTheBloodline")
    globals
        private constant integer ORDER_ID = 852190//OrderId( "curse" )
        public constant integer SPELL_ID = 'A011'

        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\NightElf\\BattleRoar\\RoarCaster.mdl"
        private real array AREA_RANGE
        private real array BONUS_CRITICAL_STRIKE_DEFENSE
        private real array DURATION
        private group ENUM_GROUP
        private real array HERO_DURATION
        private constant integer LEVELS_AMOUNT = 5
        private real array RELATIVE_DAMAGE
        private boolexpr TARGET_CONDITIONS
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\SoulBurn\\SoulBurnbuff.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
        private constant string TARGET_EFFECT2_PATH = "Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl"
        private constant string TARGET_EFFECT2_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        integer abilityLevel
        Unit array caster[LEVELS_AMOUNT]
        timer array durationTimer[LEVELS_AMOUNT]
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer abilityLevel
        local integer oldAbilityLevel = d.abilityLevel
        local integer iteration = oldAbilityLevel - 1
        local effect targetEffect
        local integer targetId
        loop
            exitwhen (durationTimer == d.durationTimer[iteration])
            set iteration = iteration - 1
        endloop
        call FlushAttachedInteger( durationTimer, CurseOfTheBloodline_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set d.durationTimer[iteration] = null
        if ( iteration > oldAbilityLevel ) then
            loop
                exitwhen (iteration < 0)
                exitwhen (d.durationTimer[iteration] != null)
                set iteration = iteration - 1
            endloop
            if ( iteration > -1 ) then
                set abilityLevel = iteration + 1
                set d.abilityLevel = abilityLevel
                call AddUnitCriticalStrikeDefense(target, BONUS_CRITICAL_STRIKE_DEFENSE[abilityLevel] - BONUS_CRITICAL_STRIKE_DEFENSE[oldAbilityLevel] )
            else
                set targetEffect = d.targetEffect
                set targetId = target.id
                call d.destroy()
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
                call FlushAttachedIntegerById( targetId, CurseOfTheBloodline_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DAMAGE" )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
                call AddUnitCriticalStrikeDefense(target, -BONUS_CRITICAL_STRIKE_DEFENSE[oldAbilityLevel] )
            endif
        endif
    endfunction

    public function Dispel takes Unit target returns nothing
        local integer abilityLevel
        local Data d = GetAttachedIntegerById(target.id, CurseOfTheBloodline_SCOPE_ID)
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
        local Data d = GetAttachedInteger(durationTimer, CurseOfTheBloodline_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    public function Damage takes real damageAmount, Unit target, Unit victim returns nothing
        local integer abilityLevel
        local texttag newTextTag
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, CurseOfTheBloodline_SCOPE_ID)
        local player targetOwner
        local unit targetSelf
        local real targetX
        local real targetY
        local real targetZ
        if (d != NULL) then
            set targetOwner = target.owner
            if ( IsUnitAlly( victim.self, targetOwner ) == false ) then
                set abilityLevel = d.abilityLevel
                set damageAmount = damageAmount * RELATIVE_DAMAGE[abilityLevel - 1]
                set targetX = GetUnitX( targetSelf )
                set targetY = GetUnitY( targetSelf )
                set targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target)
                set targetSelf = null
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, targetSelf, TARGET_EFFECT2_ATTACHMENT_POINT ) )
                set targetSelf = target.self
                call UnitDamageUnitBySpell( d.caster[abilityLevel - 1], target, damageAmount )
                set newTextTag = CreateRisingTextTag( I2S( R2I( damageAmount ) ), 0.022, targetX, targetY, targetZ, 70, 255, 128, 128, 255, 0.75, 3 )
                if ( newTextTag != null ) then
                    call LimitTextTagVisibilityToPlayer( newTextTag, targetOwner )
                    set newTextTag = null
                endif
            endif
            set targetOwner = null
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_AMOUNT, DAMAGE_SOURCE, TRIGGER_UNIT )
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
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function StartTarget takes integer abilityLevel, Unit caster, Unit target returns nothing
        local real duration
        local timer durationTimer
        local integer iteration
        local integer oldAbilityLevel
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, CurseOfTheBloodline_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set iteration = LEVELS_AMOUNT - 1
            set d.abilityLevel = abilityLevel
            set d.target = target
            loop
                if (iteration == abilityLevel) then
                    set d.caster[iteration] = caster
                    set d.durationTimer[iteration] = durationTimer
                else
                    set d.caster[iteration] = NULL
                    set d.durationTimer[iteration] = null
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call AttachInteger(durationTimer, CurseOfTheBloodline_SCOPE_ID, d)
            call AttachIntegerById(targetId, CurseOfTheBloodline_SCOPE_ID, d)
            //! runtextmacro AddEventById( "targetId", "EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        else
            set durationTimer = d.durationTimer[abilityLevel]
            set d.caster[abilityLevel - 1] = caster
            if (durationTimer == null) then
                set durationTimer = CreateTimerWJ()
                set d.durationTimer[abilityLevel - 1] = durationTimer
                call AttachInteger(durationTimer, CurseOfTheBloodline_SCOPE_ID, d)
            endif
            set oldAbilityLevel = d.abilityLevel
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call AddUnitCriticalStrikeDefense( target, BONUS_CRITICAL_STRIKE_DEFENSE[abilityLevel] )
        elseif (abilityLevel > oldAbilityLevel) then
            set d.abilityLevel = abilityLevel
            call AddUnitCriticalStrikeDefense( target, BONUS_CRITICAL_STRIKE_DEFENSE[abilityLevel] - BONUS_CRITICAL_STRIKE_DEFENSE[oldAbilityLevel] )
        endif
        if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION[abilityLevel]
        else
            set duration = DURATION[abilityLevel]
        endif
        set targetSelf = null
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local integer abilityLevel = GetUnitAbilityLevel( caster.self, SPELL_ID )
        local unit enumUnit
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, targetX, targetY ) )
        set TEMP_PLAYER = caster.owner
        call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, targetX, targetY, AREA_RANGE[abilityLevel], TARGET_CONDITIONS )
        set enumUnit = FirstOfGroup( ENUM_GROUP )
        if ( enumUnit != null ) then
            loop
                call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                call StartTarget(abilityLevel, caster, GetUnit(enumUnit))
                set enumUnit = FirstOfGroup( ENUM_GROUP )
                exitwhen ( enumUnit == null )
            endloop
        endif
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 275
        set AREA_RANGE[2] = 275
        set AREA_RANGE[3] = 275
        set AREA_RANGE[4] = 275
        set AREA_RANGE[5] = 275
        set BONUS_CRITICAL_STRIKE_DEFENSE[1] = -0.15
        set BONUS_CRITICAL_STRIKE_DEFENSE[2] = -0.18
        set BONUS_CRITICAL_STRIKE_DEFENSE[3] = -0.21
        set BONUS_CRITICAL_STRIKE_DEFENSE[4] = -0.24
        set BONUS_CRITICAL_STRIKE_DEFENSE[5] = -0.27
        set DURATION[1] = 15
        set DURATION[2] = 15
        set DURATION[3] = 15
        set DURATION[4] = 15
        set DURATION[5] = 15
        set ENUM_GROUP = CreateGroupWJ()
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Dispel_Event" )
        set HERO_DURATION[1] = 6
        set HERO_DURATION[2] = 6
        set HERO_DURATION[3] = 6
        set HERO_DURATION[4] = 6
        set HERO_DURATION[5] = 6
        set RELATIVE_DAMAGE[1] = 0.6
        set RELATIVE_DAMAGE[2] = 0.8
        set RELATIVE_DAMAGE[3] = 01
        set RELATIVE_DAMAGE[4] = 1.2
        set RELATIVE_DAMAGE[5] = 1.4
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitEffectType( AREA_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT2_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()