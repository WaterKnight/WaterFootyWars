//TESH.scrollpos=70
//TESH.alwaysfold=0
//! runtextmacro Scope("KidneyShot")
    globals
        private constant integer ORDER_ID = 852183//OrderId( "starfall" )
        public constant integer SPELL_ID = 'A06W'

        private constant real DAMAGE = 100.
        private constant real DAMAGE_PER_STRENGTH_POINT = 1.
        private constant real DURATION = 3.
        private constant real RETURNED_LIFE = 40.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Weapons\\ChimaeraLightningMissile\\ChimaeraLightningMissile.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "chest"
    endglobals

    private struct Data
        timer durationTimer
        Unit target
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer targetId = target.id
        call d.destroy()
        call FlushAttachedInteger(durationTimer, KidneyShot_SCOPE_ID)
        call DestroyTimerWJ( durationTimer )
        call RemoveIntegerFromTableById( targetId, KidneyShot_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, KidneyShot_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
    endfunction

    public function Death takes Unit target returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, KidneyShot_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById( targetId, KidneyShot_SCOPE_ID, iteration )
                call Ending( d, d.durationTimer, target )
                set iteration = iteration - 1
                exitwhen (iteration < TABLE_STARTED)
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, KidneyShot_SCOPE_ID)
        local Unit target = d.target
        call Ending( d, durationTimer, target )
        set durationTimer = null
        call AddUnitState( target.self, UNIT_STATE_LIFE, RETURNED_LIFE )
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local integer targetId = target.id
        local unit targetSelf = target.self
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
        set d.durationTimer = durationTimer
        set d.target = target
        call AttachInteger( durationTimer, KidneyShot_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, KidneyShot_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, KidneyShot_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call PlaySoundFromTypeOnUnit( KIDNEY_SHOT_SOUND_TYPE, targetSelf )
        set targetSelf = null
        call SetUnitStunTimed( target, 1, DURATION )
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
        call UnitDamageUnitEx( caster, target, DAMAGE + GetHeroStrengthTotal( caster ) * DAMAGE_PER_STRENGTH_POINT, null )
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Order takes player casterOwner, unit target returns string
        if ( IsUnitAlly( target, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( target, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_ONLY_ORGANIC
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( CASTER.owner, TARGET_UNIT.self )
    endfunction

    public function Init takes nothing returns nothing
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()