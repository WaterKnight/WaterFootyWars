//TESH.scrollpos=213
//TESH.alwaysfold=0
//! runtextmacro Scope("BondOfSouls")
    globals
        private constant integer ORDER_ID = 852480//OrderId( "magicleash" )
        public constant integer SPELL_ID = 'A00P'

        private real array BONUS_EVADE_CHANCE
        private real array DAMAGE
        private real array DURATION
        private real array DURATION_PER_AGILITY_POINT
        private constant string EFFECT_LIGHTNING_PATH = "CHIM"
        private real array HERO_DURATION
        private real array HERO_DURATION_PER_AGILITY_POINT
        private constant real INTERVAL = 0.25
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\VampiricPotion\\VampPotionCaster.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real UPDATE_TIME = 0.1
    endglobals

    private struct Data
        integer abilityLevel
        Unit caster
        timer damageTimer
        timer durationTimer
        lightning effectLightning
        sound effectSound
        Unit target
        effect targetEffect
        timer updateTimer
    endstruct

    private function Ending takes Unit caster, Data d returns nothing
        local integer abilityLevel = d.abilityLevel
        local timer damageTimer = d.damageTimer
        local timer durationTimer = d.durationTimer
        local lightning effectLightning = d.effectLightning
        local sound effectSound = d.effectSound
        local Unit target = d.target
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        local timer updateTimer = d.updateTimer
        call d.destroy()
        call FlushAttachedIntegerById( caster.id, BondOfSouls_SCOPE_ID_BASIC )
        call FlushAttachedInteger( damageTimer, BondOfSouls_SCOPE_ID )
        call DestroyTimerWJ( damageTimer )
        set damageTimer = null
        call FlushAttachedInteger( durationTimer, BondOfSouls_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call DestroyLightningWJ( effectLightning )
        set effectLightning = null
        call StopSoundWJ( effectSound, false )
        set effectSound = null
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call RemoveIntegerFromTableById( targetId, BondOfSouls_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, BondOfSouls_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        call FlushAttachedInteger( updateTimer, BondOfSouls_SCOPE_ID )
        call DestroyTimerWJ(updateTimer)
        set updateTimer = null
        call AddUnitEvasionChance( target, -BONUS_EVADE_CHANCE[abilityLevel] )
        call RemoveUnitStun( target, 0 )
    endfunction

    public function Death takes Unit target returns nothing
        local Unit caster
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, BondOfSouls_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( targetId, BondOfSouls_SCOPE_ID, iteration )
                set caster = d.caster
                call SoulVessel_TryGeneratingVessel( caster, caster.owner )
                call IssueImmediateOrderById( caster.self, STOP_ORDER_ID )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    public function EndCast takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, BondOfSouls_SCOPE_ID_BASIC )
        if ( d != NULL ) then
            call Ending( caster, d )
        endif
    endfunction

    private function EndCast_Event takes nothing returns nothing
        call EndCast( CASTER )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, BondOfSouls_SCOPE_ID)
        set durationTimer = null
        call IssueImmediateOrderById( d.caster.self, STOP_ORDER_ID )
    endfunction

    private function DealDamage takes nothing returns nothing
        local timer damageTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(damageTimer, BondOfSouls_SCOPE_ID)
        local Unit target = d.target
        set damageTimer = null
        if ( IsUnitIllusionWJ( target ) ) then
            call KillUnit( target.self )
        else
            call UnitDamageUnitBySpell( d.caster, target, DAMAGE[d.abilityLevel] )
        endif
    endfunction

    private function ResetLightning takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, BondOfSouls_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Unit target = d.target
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        set updateTimer = null
        call MoveLightningEx( d.effectLightning, true, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster), targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target) )
        set casterSelf = null
        set targetSelf = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local timer damageTimer = CreateTimerWJ()
        local real duration
        local timer durationTimer = CreateTimerWJ()
        local sound effectSound = CreateSoundFromType( BOND_OF_SOULS_SOUND_TYPE )
        local integer targetId = target.id
        local unit targetSelf = target.self
        local real targetX = GetUnitX( targetSelf )
        local real targetY = GetUnitY( targetSelf )
        local timer updateTimer = CreateTimerWJ()
        set d.abilityLevel = abilityLevel
        set d.caster = caster
        set d.damageTimer = damageTimer
        set d.durationTimer = durationTimer
        set d.effectLightning = AddLightningWJ( EFFECT_LIGHTNING_PATH, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster), targetX, targetY, GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target) )
        set casterSelf = null
        set d.effectSound = effectSound
        set d.target = target
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        set d.updateTimer = updateTimer
        call AttachIntegerById( caster.id, BondOfSouls_SCOPE_ID_BASIC, d )
        call AttachInteger( damageTimer, BondOfSouls_SCOPE_ID, d )
        call AttachInteger( durationTimer, BondOfSouls_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, BondOfSouls_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, BondOfSouls_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call AttachInteger( updateTimer, BondOfSouls_SCOPE_ID, d )
        call AttachSoundToUnit( effectSound, targetSelf )
        call StartSound( effectSound )
        set effectSound = null
        call AddUnitEvasionChance( target, BONUS_EVADE_CHANCE[abilityLevel] )
        call AddUnitStun( target, 0 )
        call TimerStart( damageTimer, INTERVAL, true, function DealDamage )
        set damageTimer = null
        call TimerStart( updateTimer, UPDATE_TIME, true, function ResetLightning )
        set updateTimer = null
        if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION[abilityLevel] + GetHeroAgility(caster) * HERO_DURATION_PER_AGILITY_POINT[abilityLevel]
        else
            set duration = DURATION[abilityLevel] + GetHeroAgility(caster) * DURATION_PER_AGILITY_POINT[abilityLevel]
        endif
        set targetSelf = null
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes Unit caster, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitMagicImmunity( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( ORDERED_UNIT, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        set BONUS_EVADE_CHANCE[1] = 0.5
        set BONUS_EVADE_CHANCE[2] = 0.5
        set BONUS_EVADE_CHANCE[3] = 0.5
        set BONUS_EVADE_CHANCE[4] = 0.5
        set BONUS_EVADE_CHANCE[5] = 0.5
        set DAMAGE[1] = 10 * INTERVAL
        set DAMAGE[2] = 15 * INTERVAL
        set DAMAGE[3] = 20 * INTERVAL
        set DAMAGE[4] = 25 * INTERVAL
        set DAMAGE[5] = 28 * INTERVAL
        set DURATION[1] = 6
        set DURATION[2] = 7
        set DURATION[3] = 7.5
        set DURATION[4] = 7.75
        set DURATION[5] = 8
        set DURATION_PER_AGILITY_POINT[1] = 0.05
        set DURATION_PER_AGILITY_POINT[2] = 0.05
        set DURATION_PER_AGILITY_POINT[3] = 0.05
        set DURATION_PER_AGILITY_POINT[4] = 0.05
        set DURATION_PER_AGILITY_POINT[5] = 0.05
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        set HERO_DURATION[1] = 3
        set HERO_DURATION[2] = 3
        set HERO_DURATION[3] = 3
        set HERO_DURATION[4] = 3
        set HERO_DURATION[5] = 3
        set HERO_DURATION_PER_AGILITY_POINT[1] = 0.02
        set HERO_DURATION_PER_AGILITY_POINT[2] = 0.02
        set HERO_DURATION_PER_AGILITY_POINT[3] = 0.02
        set HERO_DURATION_PER_AGILITY_POINT[4] = 0.02
        set HERO_DURATION_PER_AGILITY_POINT[5] = 0.02
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ENDCAST", "SPELL_ID", "UnitFinishesCasting_EVENT_KEY", "0", "function EndCast_Event" )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()