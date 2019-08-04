//TESH.scrollpos=58
//TESH.alwaysfold=0
//! runtextmacro Scope("HeartOfTheHards")
    globals
        public constant integer ITEM_ID = 'I024'
        public constant integer SET_ITEM_ID = 'I025'
        public constant integer SPELL_ID = 'A04H'

        private constant real BONUS_ARMOR_BY_SPELL = 0.15
        private constant real BONUS_MAX_LIFE = 400.
        private constant real DURATION = 5.
    endglobals

    private struct Data
        Unit caster
        timer durationTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer casterId = caster.id
        call d.destroy()
        call FlushAttachedIntegerById( casterId, HeartOfTheHards_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        call FlushAttachedInteger( durationTimer, HeartOfTheHards_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call RemoveUnitInvulnerabilityWithEffect( caster )
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, HeartOfTheHards_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, HeartOfTheHards_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local integer casterId = caster.id
        local Data d = GetAttachedIntegerById(casterId, HeartOfTheHards_SCOPE_ID)
        local timer durationTimer
        if ( d == NULL ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set d.caster = caster
            set d.durationTimer = durationTimer
            call AttachIntegerById( caster.id, HeartOfTheHards_SCOPE_ID, d )
            //! runtextmacro AddEventById( "caster.id", "EVENT_DEATH" )
            call AttachInteger( durationTimer, HeartOfTheHards_SCOPE_ID, d )
            call AddUnitInvulnerabilityWithEffect( caster )
        else
            set durationTimer = d.durationTimer
        endif
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddUnitArmorBySpellBonus( manipulatingUnit, -BONUS_ARMOR_BY_SPELL )
        call RemoveUnitCriticalStrikeImmunity( manipulatingUnit )
        call AddUnitMaxLife( manipulatingUnit, -BONUS_MAX_LIFE )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddUnitArmorBySpellBonus( manipulatingUnit, BONUS_ARMOR_BY_SPELL )
        call AddUnitCriticalStrikeImmunity( manipulatingUnit )
        call AddUnitMaxLife( manipulatingUnit, BONUS_MAX_LIFE )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 1000)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 1000)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple2(HeartStone_ITEM_ID, Lollipop_ITEM_ID, SET_ITEM_ID, ITEM_ID)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()