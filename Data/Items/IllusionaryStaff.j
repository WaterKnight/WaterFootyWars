//TESH.scrollpos=63
//TESH.alwaysfold=0
//! runtextmacro Scope("IllusionaryStaff")
    globals
        public constant integer ITEM_ID = 'I017'
        public constant integer SPELL_ID = 'A07H'

        private constant real DAMAGE_BONUS = 20.
        private constant real DURATION = 60.
        private constant real HERO_DAMAGE_FACTOR = 0.3
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Items\\AIil\\AIilTarget.mdl"
    endglobals

    public function DecayEnd takes Unit illusion returns nothing
        local integer illusionId = illusion.id
        if (GetAttachedBooleanById(illusionId, IllusionaryStaff_SCOPE_ID)) then
            call FlushAttachedBooleanById(illusionId, IllusionaryStaff_SCOPE_ID)
            //! runtextmacro RemoveEventById( "illusionId", "EVENT_DAMAGE" )
            //! runtextmacro RemoveEventById( "illusionId", "EVENT_DECAY_END" )
        endif
    endfunction

    private function DecayEnd_Event takes nothing returns nothing
        call DecayEnd( TRIGGER_UNIT )
    endfunction

    private function Damage_Conditions takes Unit target returns boolean
        set TEMP_UNIT_SELF = target.self
        if (IsUnitType(TEMP_UNIT_SELF, UNIT_TYPE_MECHANICAL)) then
            return false
        endif
        if (IsUnitType(TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE)) then
            return false
        endif
        if (GetUnitMagicImmunity(target) > 0) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit illusion, real damageAmount, Unit target returns real
        if ( GetAttachedBooleanById(illusion.id, IllusionaryStaff_SCOPE_ID) ) then
            if (Damage_Conditions(target)) then
                if (IsUnitType(illusion.self, UNIT_TYPE_HERO)) then
                    return (damageAmount + damageAmount * HERO_DAMAGE_FACTOR * ( 1 + GetUnitDamageBySpellBonus( illusion ) - GetUnitArmorBySpellBonus( target ) ))
                else
                    return (damageAmount + DAMAGE_BONUS)
                endif
            endif
        endif
        return damageAmount
    endfunction

    private function Damage_Event takes nothing returns nothing
        set DAMAGE_AMOUNT = Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local Unit illusion = CreateIllusion( target, caster.owner )
        local integer illusionId = illusion.id
        local unit illusionSelf = illusion.self
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, GetUnitX( illusionSelf ), GetUnitY( illusionSelf ) ) )
        call AttachBooleanById(illusionId, IllusionaryStaff_SCOPE_ID, true)
        //! runtextmacro AddEventById( "illusionId", "EVENT_DAMAGE" )
        //! runtextmacro AddEventById( "illusionId", "EVENT_DECAY_END" )
        call AddUnitArmorRelativeBonus( illusion, -1 )
        call UnitApplyTimedLifeWJ( illusionSelf, DURATION )
        set illusionSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 125)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 60)
        call SetItemTypeRefreshIntervalStart(d, 80)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_FOR_DAMAGE_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        //! runtextmacro CreateEvent( "EVENT_DECAY_END", "UnitFinishesDecaying_End_End_EVENT_KEY", "0", "function DecayEnd_Event" )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()