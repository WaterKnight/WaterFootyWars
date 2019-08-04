//TESH.scrollpos=14
//TESH.alwaysfold=0
//! runtextmacro Scope("GloveOfTheBeast")
    globals
        public constant integer ITEM_ID = 'I001'

        private constant real BONUS_AGILITY = 7.
        private constant real BONUS_STRENGTH = 3.
        private constant real CHANCE = 0.3
        private constant string MANIPULATING_UNIT_EFFECT_PATH = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"
        private constant string MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT = "origin"
        private constant real RESTORATION_FACTOR = 0.4
    endglobals

    private struct Data
        integer amount
    endstruct

    private function Damage_Conditions takes Unit manipulatingUnit, player manipulatingUnitOwner, unit victim returns boolean
        if ( GetAttachedIntegerById( manipulatingUnit.id, GloveOfTheBeast_SCOPE_ID ) == NULL ) then
            return false
        endif
        if ( IsUnitAlly( victim, manipulatingUnitOwner ) ) then
            return false
        endif
        if ( IsUnitType( victim, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( GetRandomReal( 0.01, 1 ) > CHANCE ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit manipulatingUnit, Unit victim returns nothing
        if ( Damage_Conditions( manipulatingUnit, manipulatingUnit.owner, victim.self ) ) then
            call DestroyEffectWJ( AddSpecialEffectTargetWJ( MANIPULATING_UNIT_EFFECT_PATH, manipulatingUnit.self, MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT ) )
            call HealUnitBySpell( manipulatingUnit, GetHeroAgilityTotal( manipulatingUnit ) * RESTORATION_FACTOR )
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function Drop takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, GloveOfTheBeast_SCOPE_ID)
        local integer amount = d.amount - 1
        local UnitType manipulatingUnitType = manipulatingUnit.type
        if (amount == 0) then
            call d.destroy()
            call FlushAttachedIntegerById( manipulatingUnitId, GloveOfTheBeast_SCOPE_ID )
            //! runtextmacro RemoveEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = amount
        endif
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, -BONUS_AGILITY )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, GloveOfTheBeast_SCOPE_ID)
        local UnitType manipulatingUnitType = manipulatingUnit.type
        if (d == NULL) then
            set d = Data.create()
            set d.amount = 1
            call AttachIntegerById( manipulatingUnitId, GloveOfTheBeast_SCOPE_ID, d )
            //! runtextmacro AddEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = d.amount + 1
        endif
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnitType, BONUS_AGILITY )
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnitType, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 750)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 50)
        call SetItemTypeRefreshIntervalStart(d, 150)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        call InitEffectType( MANIPULATING_UNIT_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()