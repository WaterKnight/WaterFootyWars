//TESH.scrollpos=97
//TESH.alwaysfold=0
//! runtextmacro Scope("VolatileManaPotion")
    globals
        public constant integer ITEM_ID = 'I00A'
        public constant integer SPELL_ID = 'A01H'

        private constant real DURATION = 20.
        private constant real INTERVAL = 1.
        private constant real LOSS_FACTOR = 0.5
        private constant real REFRESHED_MANA = 300.
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "origin"
        private constant string TARGET_EFFECT2_PATH = "Abilities\\Spells\\Undead\\ReplenishMana\\ReplenishManaCaster.mdl"
        private constant string TARGET_EFFECT2_ATTACHMENT_POINT = "origin"
        private constant integer WAVES_AMOUNT = R2I(DURATION / INTERVAL)
    endglobals

    private struct Data
        Unit caster
        real decayingManaPerInterval
        timer durationTimer
        timer intervalTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer casterId = caster.id
        local timer intervalTimer = d.intervalTimer
        call RemoveIntegerFromTableById( casterId, VolatileManaPotion_SCOPE_ID, d )
        if ( CountIntegersInTableById( casterId, VolatileManaPotion_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        endif
        call FlushAttachedInteger( durationTimer, VolatileManaPotion_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( intervalTimer, VolatileManaPotion_SCOPE_ID )
        call DestroyTimerWJ( intervalTimer )
        set intervalTimer = null
    endfunction

    public function Death takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d
        local integer iteration = CountIntegersInTableById( casterId, VolatileManaPotion_SCOPE_ID )
        if (iteration > TABLE_EMPTY) then
            loop
                set d = GetIntegerFromTableById( casterId, VolatileManaPotion_SCOPE_ID, iteration )
                call Ending( caster, d, d.durationTimer )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, VolatileManaPotion_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    private function DecayMana takes nothing returns nothing
        local timer intervalTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(intervalTimer, VolatileManaPotion_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        set intervalTimer = null
        call DestroyEffectTimed( AddSpecialEffectTargetWJ( TARGET_EFFECT2_PATH, casterSelf, TARGET_EFFECT2_ATTACHMENT_POINT ), 2 )
        call AddUnitState( casterSelf, UNIT_STATE_MANA, -d.decayingManaPerInterval )
        set casterSelf = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local real casterMana = GetUnitState( casterSelf, UNIT_STATE_MANA )
        local real casterManaDifference = GetUnitState( casterSelf, UNIT_STATE_MAX_MANA ) - casterMana
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local timer intervalTimer = CreateTimerWJ()
        local real refreshedMana = Min(casterManaDifference, REFRESHED_MANA)
        set d.caster = caster
        set d.decayingManaPerInterval = refreshedMana * LOSS_FACTOR / WAVES_AMOUNT
        set d.durationTimer = durationTimer
        set d.intervalTimer = intervalTimer
        call AddIntegerToTableById( casterId, VolatileManaPotion_SCOPE_ID, d )
        if ( CountIntegersInTableById( casterId, VolatileManaPotion_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        endif
        call AttachInteger( durationTimer, VolatileManaPotion_SCOPE_ID, d )
        call AttachInteger( intervalTimer, VolatileManaPotion_SCOPE_ID, d )
        call DestroyEffectWJ( AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, casterSelf, TARGET_EFFECT_ATTACHMENT_POINT ) )
        call PlaySoundFromTypeOnUnit( REFRESH_MANA_SOUND_TYPE, casterSelf )
        call TimerStart( intervalTimer, INTERVAL, true, function DecayMana )
        set intervalTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
        call SetUnitState( casterSelf, UNIT_STATE_MANA, casterMana + refreshedMana )
        set casterSelf = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 100)
        call SetItemTypeMaxCharges(d, 2)
        call SetItemTypeRefreshInterval(d, 40)
        call SetItemTypeRefreshIntervalStart(d, 70)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call InitEffectType( TARGET_EFFECT2_PATH )
    endfunction
//! runtextmacro Endscope()