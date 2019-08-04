//TESH.scrollpos=123
//TESH.alwaysfold=0
//! runtextmacro Scope("FrostArmor")
    globals
        public constant integer ITEM_ID = 'I01Q'
        public constant integer SET_ITEM_ID = 'I01X'

        private constant real BONUS_ARMOR = 5.
        private constant real BONUS_MAX_LIFE = 150.
    endglobals

    private struct Data
        integer amount
    endstruct

    public function Drop takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, FrostArmor_SCOPE_ID)
        local integer amount = d.amount - 1
        if (amount == NULL) then
            call d.destroy()
            call FlushAttachedIntegerById( manipulatingUnitId, FrostArmor_SCOPE_ID )
            //! runtextmacro RemoveEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = amount
        endif
        call AddUnitArmorBonus( manipulatingUnit, -BONUS_ARMOR )
        call AddUnitMaxLife( manipulatingUnit, -BONUS_MAX_LIFE )
    endfunction

    //! runtextmacro Scope("Slow")
        globals
            private constant real Slow_BONUS_ATTACK_RATE = -0.5
            private constant real Slow_BONUS_SPEED = -50.
            private constant real Slow_DURATION = 4.
            private constant string Slow_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
            private constant string Slow_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Slow_Data
            timer durationTimer
            Unit target
            effect targetEffect
        endstruct

        private function Slow_Ending takes Slow_Data d, timer durationTimer, Unit target returns nothing
            local effect targetEffect = d.targetEffect
            local integer targetId = target.id
            call d.destroy()
            call FlushAttachedInteger( durationTimer, Slow_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedIntegerById( targetId, Slow_SCOPE_ID )
            //! runtextmacro RemoveEventById( "targetId", "Slow_EVENT_DEATH" )
            call DestroyEffectWJ( targetEffect )
            set targetEffect = null
            call AddUnitAttackRate( target, -Slow_BONUS_ATTACK_RATE )
            call AddUnitSpeedBonus( target, -Slow_BONUS_SPEED )
            call RemoveUnitFrostSlow(target)
        endfunction

        public function Slow_Death takes Unit target returns nothing
            local Slow_Data d = GetAttachedIntegerById( target.id, Slow_SCOPE_ID )
            if ( d != NULL ) then
                call Slow_Ending( d, d.durationTimer, target )
            endif
        endfunction

        private function Slow_Death_Event takes nothing returns nothing
            call Slow_Death( DYING_UNIT )
        endfunction

        private function Slow_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Slow_Data d = GetAttachedInteger(durationTimer, Slow_SCOPE_ID)
            call Slow_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        public function Slow_Start takes Unit target returns nothing
            local timer durationTimer
            local integer targetId = target.id
            local Slow_Data d = GetAttachedIntegerById( targetId, Slow_SCOPE_ID )
            if ( d == NULL ) then
                set d = Slow_Data.create()
                set durationTimer = CreateTimerWJ()
                set d.durationTimer = durationTimer
                set d.target = target
                call AttachInteger( durationTimer, Slow_SCOPE_ID, d )
                call AttachIntegerById( targetId, Slow_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "Slow_EVENT_DEATH" )
                call AddUnitAttackRate( target, Slow_BONUS_ATTACK_RATE )
                call AddUnitSpeedBonus( target, Slow_BONUS_SPEED )
                call AddUnitFrostSlow(target)
            else
                set durationTimer = d.durationTimer
                call DestroyEffectWJ( d.targetEffect )
            endif
            set d.targetEffect = AddSpecialEffectTargetWJ( Slow_TARGET_EFFECT_PATH, target.self, Slow_TARGET_EFFECT_ATTACHMENT_POINT )
            call TimerStart( durationTimer, Slow_DURATION, false, function Slow_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Slow_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Slow_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Slow_Death_Event" )
        endfunction
    //! runtextmacro Endscope()

    private function Damage_TargetConditions takes Unit manipulatingUnit, unit target returns boolean
        if ( GetAttachedIntegerById(manipulatingUnit.id, FrostArmor_SCOPE_ID) == NULL ) then
            return false
        endif
        if (GetUnitState(target, UNIT_STATE_LIFE) <= 0) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        if ( IsUnitType( target, UNIT_TYPE_MELEE_ATTACKER ) == false ) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit manipulatingUnit, Unit target returns nothing
        if ( Damage_TargetConditions( manipulatingUnit, target.self ) ) then
            call Slow_Slow_Start(target)
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( TRIGGER_UNIT, DAMAGE_SOURCE )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, FrostArmor_SCOPE_ID)
        if (d == NULL) then
            set d = Data.create()
            set d.amount = 1
            call AttachIntegerById( manipulatingUnitId, FrostArmor_SCOPE_ID, d )
            //! runtextmacro AddEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = d.amount + 1
        endif
        call AddUnitArmorBonus( manipulatingUnit, BONUS_ARMOR )
        call AddUnitMaxLife( manipulatingUnit, BONUS_MAX_LIFE )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 1000)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 1000)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple2(FrozenShard_ITEM_ID, HeartStone_ITEM_ID, SET_ITEM_ID, ITEM_ID)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY", "0", "function Damage_Event" )
        call Slow_Slow_Init()
    endfunction
//! runtextmacro Endscope()