//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("SilverSpores")
    globals
        private constant integer ORDER_ID = 852069//OrderId( "invisibility" )
        public constant integer SPELL_ID = 'A03F'

        private constant real BONUS_ALPHA = -127.
        private constant real DURATION = 30.
        private constant real FADE_TIME = 1.
        private constant real HERO_DURATION = 10.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\NightElf\\FaerieDragonInvis\\FaerieDragon_Invis.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
    endglobals

    private struct Data
        timer dummyTimer
        boolean isInvisible
        Unit target
    endstruct

    private function Ending takes Data d, timer dummyTimer, Unit target returns nothing
        local boolean isInvisible = d.isInvisible
        local integer targetId = target.id
        call FlushAttachedInteger( dummyTimer, SilverSpores_SCOPE_ID )
        call DestroyTimerWJ( dummyTimer )
        call FlushAttachedIntegerById( targetId, SilverSpores_SCOPE_ID )
        //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        if (isInvisible) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
            call RemoveUnitInvisibility( target )
        else
            call RemoveUnitAttackSilence(target)
        endif
        call AddUnitVertexColorTimed( target, 0, 0, 0, -BONUS_ALPHA, null, FADE_TIME )
    endfunction

    public function Dispel takes Unit target returns nothing
        local Data d = GetAttachedIntegerById( target.id, SilverSpores_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( d, d.dummyTimer, target )
        endif
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    public function Attack takes Unit target returns nothing
        call Dispel( target )
    endfunction

    public function BeginCast takes Unit target returns nothing
        call Dispel( target )
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel( target )
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer dummyTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(dummyTimer, SilverSpores_SCOPE_ID)
        call Ending( d, dummyTimer, d.target )
        set dummyTimer = null
    endfunction

    private function SetInvisible takes nothing returns nothing
        local timer dummyTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(dummyTimer, SilverSpores_SCOPE_ID)
        local real duration
        local Unit target = d.target
        call RemoveUnitAttackSilence(target)
        set d.isInvisible = true
        //! runtextmacro AddEventById( "target.id", "EVENT_DISPEL" )
        call AddUnitInvisibility( target )
        if ( IsUnitType( target.self, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION
        else
            set duration = DURATION
        endif
        call TimerStart( dummyTimer, duration, false, function EndingByTimer )
        set dummyTimer = null
    endfunction

    public function SpellEffect takes Unit target returns nothing
        local timer dummyTimer
        local real duration
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, SilverSpores_SCOPE_ID)
        local unit targetSelf = target.self
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
        if ( d == NULL ) then
            set d = Data.create()
            set dummyTimer = CreateTimerWJ()
            set d.dummyTimer = dummyTimer
            set d.isInvisible = false
            set d.target = target
            call AttachInteger( dummyTimer, SilverSpores_SCOPE_ID, d )
            call AttachIntegerById( targetId, SilverSpores_SCOPE_ID, d )
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            call AddUnitAttackSilence(target)
            call AddUnitVertexColorTimed( target, 0, 0, 0, BONUS_ALPHA, null, FADE_TIME )
            call TimerStart( dummyTimer, FADE_TIME, false, function SetInvisible )
        elseif (d.isInvisible) then
            set dummyTimer = d.dummyTimer
            if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
                set duration = HERO_DURATION
            else
                set duration = DURATION
            endif
            call TimerStart( dummyTimer, duration, false, function EndingByTimer )
        endif
        set dummyTimer = null
        if ( GetUnitCurrentOrder( targetSelf ) == ATTACK_ORDER_ID ) then
            call IssueImmediateOrderById(targetSelf, STOP_ORDER_ID)
        endif
        set targetSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) == false ) then
            return ErrorStrings_ONLY_ALLY
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
        set ERROR_MSG = Order( ORDERED_UNIT.owner, TARGET_UNIT )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_POSITIVE", "0", "function Dispel_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()