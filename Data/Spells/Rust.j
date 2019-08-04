//TESH.scrollpos=83
//TESH.alwaysfold=0
//! runtextmacro Scope("Rust")
    globals
        private constant integer ORDER_ID = 852189//OrderId( "cripple" )
        public constant integer SPELL_ID = 'A03J'

        private constant real BONUS_RELATIVE_ATTACK_RATE = -0.3
        private constant real BONUS_SPEED_RELATIVE = -0.2
        private constant real DURATION = 20.
        private constant real HERO_DURATION = 7.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
    endglobals

    private struct Data
        real bonusSpeed
        timer durationTimer
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local real bonusSpeed = d.bonusSpeed
        local effect targetEffect = d.targetEffect
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger( durationTimer, Rust_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedIntegerById( targetId, Rust_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
        call DestroyEffectWJ( targetEffect )
        set targetEffect = null
        call AddUnitAttackRate( target, -BONUS_RELATIVE_ATTACK_RATE )
        call AddUnitSpeedBonus( target, -bonusSpeed )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById(target.id, Rust_SCOPE_ID)
        if ( d != NULL ) then
            call Ending( d, d.durationTimer, target )
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
        local Data d = GetAttachedInteger(durationTimer, Rust_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit target returns nothing
        local real duration
        local timer durationTimer
        local real newBonusSpeed = GetUnitSpeedTotal( target ) * BONUS_SPEED_RELATIVE
        local real oldBonusSpeed
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, Rust_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.durationTimer = durationTimer
            set d.target = target
            call AttachInteger( durationTimer, Rust_SCOPE_ID, d )
            call AttachIntegerById( targetId, Rust_SCOPE_ID, d )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        else
            set durationTimer = d.durationTimer
            set oldBonusSpeed = d.bonusSpeed
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.bonusSpeed = newBonusSpeed
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call AddUnitAttackRate( target, BONUS_RELATIVE_ATTACK_RATE )
            call AddUnitSpeedBonus( target, newBonusSpeed )
        else
            call AddUnitSpeedBonus( target, newBonusSpeed - oldBonusSpeed )
        endif
        if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION
        else
            set duration = DURATION
        endif
        set targetSelf = target.self
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( IsUnitWard( target ) ) then
            return ErrorStrings_NOT_WARD
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( CASTER.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Dispel_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()