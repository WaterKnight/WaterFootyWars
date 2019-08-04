//TESH.scrollpos=112
//TESH.alwaysfold=0
//! runtextmacro Scope("HealingPotionBloodOrange")
    globals
        public constant integer ITEM_ID = 'I028'
        public constant integer SPELL_ID = 'A080'

        private constant string CASTER_EFFECT_PATH = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"
        private constant string CASTER_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string CASTER_EFFECT2_PATH = "Abilities\\Spells\\Undead\\Possession\\PossessionTarget.mdl"
        private constant string CASTER_EFFECT2_ATTACHMENT_POINT = "overhead"
        private constant real DURATION = 15.
        private constant real REFRESHED_LIFE = 200.
        private constant real RESTORATION_FACTOR = 0.15
    endglobals

    private struct Data
        Unit caster
        effect casterEffect
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local effect casterEffect = d.casterEffect
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, HealingPotionBloodOrange_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DISPEL" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DAMAGE" )
        call DestroyEffectWJ( casterEffect )
        set casterEffect = null
        call FlushAttachedInteger( durationTimer, HealingPotionBloodOrange_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
    endfunction

    public function Dispel takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById(caster.id, HealingPotionBloodOrange_SCOPE_ID)
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
        local Data d = GetAttachedInteger(durationTimer, HealingPotionBloodOrange_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    private function Damage_Conditions takes Unit caster, player casterOwner, unit target returns boolean
        if ( GetAttachedIntegerById( caster.id, HealingPotionBloodOrange_SCOPE_ID ) == NULL ) then
            return false
        endif
        if ( IsUnitAlly( target, casterOwner ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit caster, real damageAmount, Unit target returns nothing
        if ( Damage_Conditions( caster, caster.owner, target.self ) ) then
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( CASTER_EFFECT2_PATH, caster.self, CASTER_EFFECT2_ATTACHMENT_POINT ) )
            call HealUnitBySpell( caster, damageAmount * RESTORATION_FACTOR )
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local Data d = GetAttachedIntegerById(casterId, HealingPotionBloodOrange_SCOPE_ID)
        local timer durationTimer
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, caster.self, CASTER_EFFECT_ATTACHMENT_POINT ), 2 )
        if ( d == NULL ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById( casterId, HealingPotionBloodOrange_SCOPE_ID, d )
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DISPEL" )
            //! runtextmacro AddEventById( "casterId", "EVENT_DAMAGE" )
            call AttachInteger( durationTimer, HealingPotionBloodOrange_SCOPE_ID, d )
        else
            set durationTimer = d.durationTimer
            call DestroyEffectWJ( d.casterEffect )
        endif
        set d.casterEffect = AddSpecialEffectTargetWJ( CASTER_EFFECT_PATH, casterSelf, CASTER_EFFECT_ATTACHMENT_POINT )
        call PlaySoundFromTypeAtPosition( POTION_OF_THE_INCONSPICUOUS_SHAPE_SOUND_TYPE, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) )
        set casterSelf = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
        call HealUnitBySpell( caster, REFRESHED_LIFE )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 175)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 60)
        call SetItemTypeRefreshIntervalStart(d, 60)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call InitEffectType( CASTER_EFFECT_PATH )
        call InitEffectType( CASTER_EFFECT2_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()