//TESH.scrollpos=125
//TESH.alwaysfold=0
//! runtextmacro Scope("WindBoots")
    globals
        public constant integer ITEM_ID = 'I00B'
        public constant integer SET_ITEM_ID = 'I022'
        public constant integer SPELL_ID = 'A04E'

        private constant real BONUS_AGILITY = 6.
        private constant real BONUS_SPEED = 25.
        private constant integer DUMMY_UNIT_ID = 'n02K'
        private constant real DUMMY_UNIT_HEIGHT = 150
        private constant real MAX_LENGTH = 550.
        private constant string SPECIAL_EFFECT_PATH = "Abilities\\Spells\\Human\\FlakCannons\\FlakTarget.mdl"
        private constant real SPEED = 700.
        private constant real DURATION = MAX_LENGTH / SPEED
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        Unit caster
        unit dummyUnit
        timer durationTimer
        real lengthX
        real lengthY
        timer updateTimer
    endstruct

    private function Ending takes Unit caster, Data d, timer durationTimer returns nothing
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local unit dummyUnit = d.dummyUnit
        local timer updateTimer = d.updateTimer
        call FlushAttachedIntegerById( casterId, WindBoots_SCOPE_ID )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro RemoveEventById( "casterId", "EVENT_ORDER" )
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call RemoveUnitTimed( dummyUnit, 4 )
        call FlushAttachedInteger( durationTimer, WindBoots_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        call FlushAttachedInteger( updateTimer, WindBoots_SCOPE_ID )
        call DestroyTimerWJ( updateTimer )
        set updateTimer = null
        call AddUnitPathing( caster )
        call SetUnitPosition( casterSelf, GetUnitX( casterSelf ), GetUnitY( casterSelf ) )
        set casterSelf = null
    endfunction

    public function Death takes Unit caster returns nothing
        local Data d = GetAttachedIntegerById( caster.id, WindBoots_SCOPE_ID )
        if ( d != NULL ) then
            call Ending( caster, d, d.durationTimer )
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        call Death(DYING_UNIT)
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, WindBoots_SCOPE_ID)
        call Ending( d.caster, d, durationTimer )
        set durationTimer = null
    endfunction

    private function Move takes nothing returns nothing
        local timer updateTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(updateTimer, WindBoots_SCOPE_ID)
        local Unit caster = d.caster
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local unit dummyUnit = d.dummyUnit
        local real newX = casterX + d.lengthX
        local real newY = casterY + d.lengthY
        set updateTimer = null
        call DestroyEffectWJ( AddSpecialEffectWJ( SPECIAL_EFFECT_PATH, newX, newY ) )
        call SetUnitXYIfNotBlocked( casterSelf, casterX, casterY, newX, newY )
        call SetUnitXWJ( dummyUnit, newX )
        call SetUnitYWJ( dummyUnit, newY )
        call SetUnitZ( dummyUnit, newX, newY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster) + DUMMY_UNIT_HEIGHT )
        set casterSelf = null
        set dummyUnit = null
    endfunction

    public function SpellEffect takes Unit caster, real targetX, real targetY returns nothing
        local real angle
        local integer casterId = caster.id
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, DUMMY_UNIT_ID, casterX, casterY, STANDARD_ANGLE )
        local timer durationTimer = CreateTimerWJ()
        local timer updateTimer = CreateTimerWJ()
        if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
            set angle = Atan2( targetY - casterY, targetX - casterX )
        else
            set angle = GetUnitFacingWJ( casterSelf )
        endif
        set d.caster = caster
        set d.dummyUnit = dummyUnit
        set d.durationTimer = durationTimer
        set d.lengthX = LENGTH * Cos(angle)
        set d.lengthY = LENGTH * Sin(angle)
        set d.updateTimer = updateTimer
        call AttachIntegerById( casterId, WindBoots_SCOPE_ID, d )
        //! runtextmacro AddEventById( "casterId", "EVENT_DEATH" )
        //! runtextmacro AddEventById( "casterId", "EVENT_ORDER" )
        call AttachInteger( durationTimer, WindBoots_SCOPE_ID, d )
        call AttachInteger( updateTimer, WindBoots_SCOPE_ID, d )
        call RemoveUnitPathing( caster )
        call SetUnitTimeScale( dummyUnit, 2 )
        call SetUnitAnimationByIndex( dummyUnit, 2 )
        call SetUnitAnimationByIndex( dummyUnit, 0 )
        call SetUnitZ( dummyUnit, casterX, casterY, GetUnitZ( casterSelf, casterX, casterY ) + GetUnitImpactZ(caster) + DUMMY_UNIT_HEIGHT )
        set casterSelf = null
        set dummyUnit = null
        call TimerStart( updateTimer, UPDATE_TIME, true, function Move )
        set updateTimer = null
        call TimerStart( durationTimer, DURATION, false, function EndingByTimer )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_X, TARGET_Y )
    endfunction

    public function Order takes Unit caster returns string
    //    local Data d = GetAttachedInteger(caster, WindBoots_SCOPE_ID)
    //    if ( d != NULL ) then
    //        return ""
    //    endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        call Order( ORDERED_UNIT )
    endfunction

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnit.type, -BONUS_AGILITY )
        call AddUnitSpeedBonus( manipulatingUnit, -BONUS_SPEED )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddHeroAgilityBonus( manipulatingUnit, manipulatingUnit.type, BONUS_AGILITY )
        call AddUnitSpeedBonus( manipulatingUnit, BONUS_SPEED )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 350)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 350)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple3(GexxoSlippers_ITEM_ID, GexxoSlippers_ITEM_ID, GexxoSlippers_ITEM_ID, SET_ITEM_ID, ITEM_ID)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_ORDER", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitEffectType( SPECIAL_EFFECT_PATH )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()