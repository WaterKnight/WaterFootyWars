//TESH.scrollpos=15
//TESH.alwaysfold=0
//! runtextmacro Scope("FenixsFeather")
    globals
        public constant integer ITEM_ID = 'I023'

        private constant real BONUS_DAMAGE = 60.
        private constant real BONUS_MAX_MANA = 250.
        private constant real KILL_CHANCE = 0.05
        private constant string KILL_EFFECT_PATH = "Abilities\\Spells\\Items\\WandOfNeutralization\\NeutralizationMissile.mdl"
        private constant string KILL_EFFECT_ATTACHMENT_POINT = "chest"
        private constant real STUN_CHANCE = 0.15
        private constant real STUN_DURATION = 5.
    endglobals

    private struct Data
        integer amount
    endstruct

    private function Conditions takes Unit manipulatingUnit, player manipulatingUnitOwner, unit target returns boolean
        if (GetAttachedIntegerById( manipulatingUnit.id, FenixsFeather_SCOPE_ID ) == NULL) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_HERO ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit manipulatingUnit, Unit target returns nothing
        local unit targetSelf = target.self
        local UnitType targetType
        if (Conditions( manipulatingUnit, manipulatingUnit.owner, targetSelf )) then
            set targetType = target.type
            if ( GetRandomReal( 0.01, 1 ) <= STUN_CHANCE ) then
                call SetUnitStunTimed( target, 1, STUN_DURATION )
            endif
            if ((IsUnitTypeSpawn(targetType) or (targetType.id == RESERVE_UNIT_ID)) and GetRandomReal(0.01, 1) <= KILL_CHANCE) then
                call DestroyEffectWJ( AddSpecialEffectTargetWJ( KILL_EFFECT_PATH, targetSelf, KILL_EFFECT_ATTACHMENT_POINT ) )
                call UnitDamageUnitEx( manipulatingUnit, target, GetUnitState(targetSelf, UNIT_STATE_LIFE), null )
            endif
        endif
        set targetSelf = null
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function Drop takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, FenixsFeather_SCOPE_ID)
        local integer amount = d.amount - 1
        if (amount == 0) then
            call d.destroy()
            call FlushAttachedIntegerById( manipulatingUnitId, FenixsFeather_SCOPE_ID )
            //! runtextmacro RemoveEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = amount
        endif
        call AddUnitDamageBonus( manipulatingUnit, -BONUS_DAMAGE )
        call AddUnitMaxMana( manipulatingUnit, -BONUS_MAX_MANA )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, FenixsFeather_SCOPE_ID)
        if (d == NULL) then
            set d = Data.create()
            set d.amount = 1
            call AttachIntegerById( manipulatingUnitId, FenixsFeather_SCOPE_ID, d )
            //! runtextmacro AddEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = d.amount + 1
        endif
        call AddUnitDamageBonus( manipulatingUnit, BONUS_DAMAGE )
        call AddUnitMaxMana( manipulatingUnit, BONUS_MAX_MANA )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 3500)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 240)
        call SetItemTypeRefreshIntervalStart(d, 500)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        call InitEffectType( KILL_EFFECT_PATH )
    endfunction
//! runtextmacro Endscope()