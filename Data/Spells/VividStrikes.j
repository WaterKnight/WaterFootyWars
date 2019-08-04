//TESH.scrollpos=107
//TESH.alwaysfold=0
//! runtextmacro Scope("VividStrikes")
    globals
        private constant integer ORDER_ID = 852157//OrderId( "recharge" )
        public constant integer SPELL_ID = 'A06T'

        private constant real ABSORPTION_FACTOR_START = 0.03
        private constant real ABSORPTION_FACTOR_START_PER_INTELLIGENCE_POINT = 0.00033
        private constant real ABSORPTION_FACTOR_ADD = 0.01
        private constant real ABSORPTION_FACTOR_ADD_PER_INTELLIGENCE_POINT = 0.00011
        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Items\\VampiricPotion\\VampPotionCaster.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string CASTER_EFFECT2_PATH = "VividStrikesCaster2.mdl"
        private constant string CASTER_EFFECT2_ATTACHMENT_POINT = "origin"
        private constant real DAMAGE_FACTOR = 0.01
        private constant real DAMAGE_FACTOR_PER_INTELLIGENCE_POINT = 0.00033
        private constant real DURATION = 15.
        private constant string EFFECT_SOUND_PATH = "VividStrikes"
        private constant integer MAX_STRIKES_AMOUNT = 5
        private constant string TARGET_EFFECT_PATH = "Abilities\\Weapons\\MeatwagonMissile\\MeatwagonMissile.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
    endglobals

    private struct Data
        real absorptionFactor
        real absorptionFactorAdd
        Unit caster
        effect casterEffect
        real damageFactor
        timer durationTimer
        integer strikesAmount
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local effect casterEffect = d.casterEffect
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, VividStrikes_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
    //    //! runtextmacro RemoveEventById( "casterId", "EVENT_DISPEL" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call FlushAttachedInteger( durationTimer, VividStrikes_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
    endfunction

    public function Dispel takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, VividStrikes_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Death takes Unit caster returns nothing
        call Dispel( caster )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, VividStrikes_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    private function Damage_Conditions takes player casterOwner, Unit target returns boolean
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitIllusionWJ( target ) ) then
            return false
        endif
        if ( IsUnitWard( target ) ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns real
        local real absorptionFactor
        local unit casterSelf
        local Data d = GetAttachedIntegerById(caster.id, VividStrikes_SCOPE_ID)
        local integer strikesAmount
        local unit targetSelf
        if (d != NULL) then
            if ( Damage_Conditions( caster.owner, target ) ) then
                set absorptionFactor = d.absorptionFactor
                set casterSelf = caster.self
                set strikesAmount = d.strikesAmount + 1
                set targetSelf = target.self
                set damageAmount = damageAmount + d.damageFactor * GetUnitState( targetSelf, UNIT_STATE_MAX_LIFE )
                if ( strikesAmount >= MAX_STRIKES_AMOUNT ) then
                    call Ending( caster, d, d.durationTimer )
                else
                    set d.absorptionFactor = absorptionFactor + d.absorptionFactorAdd
                    set d.strikesAmount = strikesAmount
                endif
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT2_PATH, casterSelf, CASTER_EFFECT2_ATTACHMENT_POINT ) )
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_PATH ) )
                call HealUnitBySpell( caster, absorptionFactor * GetUnitState( casterSelf, UNIT_STATE_MAX_LIFE ) )
                set casterSelf = null
            endif
            set targetSelf = null
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, VividStrikes_SCOPE_ID)
        local real casterIntelligence = GetHeroIntelligenceTotal( caster )
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local timer durationTimer
        if ( d == NULL ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById( casterId, VividStrikes_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
    //        //! runtextmacro AddEventById( "casterId", "EVENT_DISPEL" )
            call AttachInteger( durationTimer, VividStrikes_SCOPE_ID, d )
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.casterEffect )
        endif
        set d.absorptionFactor = ABSORPTION_FACTOR_START + casterIntelligence * ABSORPTION_FACTOR_START_PER_INTELLIGENCE_POINT
        set d.absorptionFactorAdd = ABSORPTION_FACTOR_ADD + casterIntelligence * ABSORPTION_FACTOR_ADD_PER_INTELLIGENCE_POINT
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
        set casterSelf = null
        set d.damageFactor = DAMAGE_FACTOR + casterIntelligence * DAMAGE_FACTOR_PER_INTELLIGENCE_POINT
        set d.strikesAmount = 0
    //    call PlaySoundFromLabelAtPosition( EFFECT_SOUND_PATH, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_UNBLOCKABLE_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
    //    //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitEffectType( CASTER_EFFECT2_PATH )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()