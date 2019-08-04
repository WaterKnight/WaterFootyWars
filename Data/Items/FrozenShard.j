//TESH.scrollpos=95
//TESH.alwaysfold=0
//! runtextmacro Scope("FrozenShard")
    globals
        public constant integer ITEM_ID = 'I026'

        private constant real BONUS_ARMOR = 1.
        private constant real BONUS_MAX_LIFE = -30.
        private constant string MANIPULATING_UNIT_EFFECT_PATH = "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl"
        private constant string MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT = "weapon"
    endglobals

    private struct Data
        integer amount
        effect manipulatingUnitEffect
    endstruct

    //! runtextmacro Scope("Buff")
        globals
            private constant real Buff_BONUS_SPEED_START = -30.
            private constant real Buff_BONUS_SPEED_ADD = -30.
            private constant real Buff_DURATION = 4.
            private constant string Buff_TARGET_EFFECT_PATH = "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl"
            private constant string Buff_TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        endglobals

        private struct Buff_Data
            real bonusSpeed
            timer durationTimer
            Unit target
            effect targetEffect
        endstruct

        private function Buff_Ending takes Buff_Data d, timer durationTimer, Unit target returns nothing
            local real bonusSpeed = d.bonusSpeed
            local effect targetEffect = d.targetEffect
            local integer targetId = target.id
            call d.destroy()
            call FlushAttachedInteger( durationTimer, Buff_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call FlushAttachedIntegerById( targetId, Buff_SCOPE_ID )
            //! runtextmacro RemoveEventById( "targetId", "Buff_EVENT_DEATH" )
            call DestroyEffectWJ( targetEffect )
            set targetEffect = null
            call AddUnitSpeedBonus( target, -bonusSpeed )
            call RemoveUnitFrostSlow(target)
        endfunction

        public function Buff_Death takes Unit target returns nothing
            local Buff_Data d = GetAttachedIntegerById( target.id, Buff_SCOPE_ID )
            if ( d != NULL ) then
                call Buff_Ending( d, d.durationTimer, target )
            endif
        endfunction

        private function Buff_Death_Event takes nothing returns nothing
            call Buff_Death( DYING_UNIT )
        endfunction

        private function Buff_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Buff_Data d = GetAttachedInteger(durationTimer, Buff_SCOPE_ID)
            call Buff_Ending( d, durationTimer, d.target )
            set durationTimer = null
        endfunction

        public function Buff_Start takes integer amount, Unit target returns nothing
            local real bonusSpeed = Buff_BONUS_SPEED_START + (amount - 1) * Buff_BONUS_SPEED_ADD
            local timer durationTimer
            local real oldBonusSpeed
            local integer targetId = target.id
            local Buff_Data d = GetAttachedIntegerById( targetId, Buff_SCOPE_ID )
            local boolean isNew = (d == NULL)
            local unit targetSelf = target.self
            if ( isNew ) then
                set d = Buff_Data.create()
                set durationTimer = CreateTimerWJ()
                set d.bonusSpeed = bonusSpeed
                set d.durationTimer = durationTimer
                set d.target = target
                call AttachInteger( durationTimer, Buff_SCOPE_ID, d )
                call AttachIntegerById( targetId, Buff_SCOPE_ID, d )
                //! runtextmacro AddEventById( "targetId", "Buff_EVENT_DEATH" )
            else
                set durationTimer = d.durationTimer
                set oldBonusSpeed = d.bonusSpeed
                call DestroyEffectWJ( d.targetEffect )
            endif
            set d.targetEffect = AddSpecialEffectTargetWJ( Buff_TARGET_EFFECT_PATH, targetSelf, Buff_TARGET_EFFECT_ATTACHMENT_POINT )
            set targetSelf = null
            if (isNew) then
                call AddUnitSpeedBonus( target, bonusSpeed )
                call AddUnitFrostSlow(target)
            elseif (bonusSpeed > oldBonusSpeed) then
                set d.bonusSpeed = bonusSpeed
                call AddUnitSpeedBonus( target, bonusSpeed - oldBonusSpeed )
            endif
            call TimerStart( durationTimer, Buff_DURATION, false, function Buff_EndingByTimer )
            set durationTimer = null
        endfunction

        public function Buff_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Buff_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Buff_Death_Event" )
            call InitEffectType( Buff_TARGET_EFFECT_PATH )
        endfunction
    //! runtextmacro Endscope()

    private function Damage_Conditions takes Unit manipulatingUnit, Unit target returns boolean
        if (GetUnitTypeSpeed(target.type) <= 0) then
            return false
        endif
        return true
    endfunction

    public function Damage takes Unit manipulatingUnit, Unit target returns nothing
        local Data d = GetAttachedIntegerById( manipulatingUnit.id, FrozenShard_SCOPE_ID )
        if (d != NULL) then
            if (Damage_Conditions(manipulatingUnit, target)) then
                call Buff_Buff_Start(d.amount, target)
            endif
        endif
    endfunction

    private function Damage_Event takes nothing returns nothing
        call Damage( DAMAGE_SOURCE, TRIGGER_UNIT )
    endfunction

    public function Drop takes Unit manipulatingUnit returns nothing
        local effect manipulatingUnitEffect
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, FrozenShard_SCOPE_ID)
        local integer amount = d.amount - 1
        if (amount == NULL) then
            set manipulatingUnitEffect = d.manipulatingUnitEffect
            call d.destroy()
            call DestroyEffectWJ( manipulatingUnitEffect )
            set manipulatingUnitEffect = null
            call FlushAttachedIntegerById( manipulatingUnitId, FrozenShard_SCOPE_ID )
            //! runtextmacro RemoveEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = amount
        endif
        call AddUnitArmorBonus( manipulatingUnit, -BONUS_ARMOR )
        call AddUnitMaxLife( manipulatingUnit, -BONUS_MAX_LIFE )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        local integer manipulatingUnitId = manipulatingUnit.id
        local Data d = GetAttachedIntegerById(manipulatingUnitId, FrozenShard_SCOPE_ID)
        if (d == NULL) then
            set d = Data.create()
            set d.amount = 1
            set d.manipulatingUnitEffect = AddSpecialEffectTargetWJ( MANIPULATING_UNIT_EFFECT_PATH, manipulatingUnit.self, MANIPULATING_UNIT_EFFECT_ATTACHMENT_POINT )
            call AttachIntegerById( manipulatingUnitId, FrozenShard_SCOPE_ID, d )
            //! runtextmacro AddEventById( "manipulatingUnitId", "EVENT_DAMAGE" )
        else
            set d.amount = d.amount + 1
        endif
        call AddUnitArmorBonus( manipulatingUnit, BONUS_ARMOR )
        call AddUnitMaxLife( manipulatingUnit, BONUS_MAX_LIFE )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 250)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 40)
        call SetItemTypeRefreshIntervalStart(d, 200)

        //! runtextmacro CreateEvent( "EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_PRIMARY_AS_DAMAGE_SOURCE", "0", "function Damage_Event" )
        call Buff_Buff_Init()
    endfunction
//! runtextmacro Endscope()