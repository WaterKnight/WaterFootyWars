//TESH.scrollpos=129
//TESH.alwaysfold=0
//! runtextmacro Scope("SuperCarrot")
    globals
        public constant integer ITEM_ID = 'I016'
        public constant integer SPELL_ID = 'A07D'

        private constant string AREA_EFFECT_PATH = "Abilities\\Spells\\Human\\Flare\\FlareCaster.mdl"
        private constant integer DUMMY_UNIT_ID = 'n02U'
        private constant real DURATION = 30.
    endglobals

    private struct Data
        fogmodifier dummyFogModifier
        unit dummyUnit
        timer durationTimer
    endstruct

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, SuperCarrot_SCOPE_ID)
        local fogmodifier dummyFogModifier = d.dummyFogModifier
        local unit dummyUnit = d.dummyUnit
        local player casterOwner = GetOwningPlayer( dummyUnit )
        call d.destroy()
        call FlushAttachedInteger( casterOwner, SuperCarrot_SCOPE_ID )
        set casterOwner = null
        call DestroyFogModifierWJ( dummyFogModifier )
        set dummyFogModifier = null
        call RemoveUnitWJ( dummyUnit )
        set dummyUnit = null
        call FlushAttachedInteger( durationTimer, SuperCarrot_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
    endfunction

    //! runtextmacro Scope("Effect")
        globals
            private constant integer Effect_DUMMY_UNIT_ID = 'n02V'
            private constant real Effect_DURATION = 1.
            private constant real Effect_HEIGHT_START = 200.
            private constant real Effect_UPDATE_TIME = 0.035
            private constant real Effect_HEIGHT_ADD = 1100 * Effect_UPDATE_TIME
        endglobals

        private struct Effect_Data
            unit dummyUnit
            timer durationTimer
            timer updateTimer
        endstruct

        private function Effect_Ending takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Effect_Data d = GetAttachedInteger(durationTimer, Effect_SCOPE_ID)
            local unit dummyUnit = d.dummyUnit
            local timer updateTimer = d.updateTimer
            call d.destroy()
            call RemoveUnitWJ( dummyUnit )
            set dummyUnit = null
            call FlushAttachedInteger( durationTimer, Effect_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            set durationTimer = null
            call FlushAttachedInteger( updateTimer, Effect_SCOPE_ID )
            call DestroyTimerWJ( updateTimer )
            set updateTimer = null
        endfunction

        private function Effect_Move takes nothing returns nothing
            local timer updateTimer = GetExpiredTimer()
            local Effect_Data d = GetAttachedInteger(updateTimer, Effect_SCOPE_ID)
            local unit dummyUnit = d.dummyUnit
            local real dummyUnitX = GetUnitX(dummyUnit)
            local real dummyUnitY = GetUnitY(dummyUnit)
            local real newZ = GetUnitZ( dummyUnit, dummyUnitX, dummyUnitY ) + Effect_HEIGHT_ADD
            set updateTimer = null
            call SetUnitZ( dummyUnit, dummyUnitX, dummyUnitY, newZ )
            set dummyUnit = null
        endfunction

        public function Effect_Start takes player casterOwner, real x, real y returns nothing
            local Effect_Data d = Effect_Data.create()
            local unit dummyUnit = CreateUnitWJ( casterOwner, Effect_DUMMY_UNIT_ID, x, y, 0 )
            local timer durationTimer = CreateTimerWJ()
            local timer updateTimer = CreateTimerWJ()
            set d.dummyUnit = dummyUnit
            set d.durationTimer = durationTimer
            set d.updateTimer = updateTimer
            call AttachInteger( durationTimer, Effect_SCOPE_ID, d )
            call AttachInteger( updateTimer, Effect_SCOPE_ID, d )
            call SetUnitZ( dummyUnit, x, y, Effect_HEIGHT_START )
            set dummyUnit = null
            call TimerStart( updateTimer, Effect_UPDATE_TIME, true, function Effect_Move )
            set updateTimer = null
            call TimerStart( durationTimer, Effect_DURATION, false, function Effect_Ending )
            set durationTimer = null
        endfunction

        public function Effect_Init takes nothing returns nothing
            call InitUnitType( Effect_DUMMY_UNIT_ID )
        endfunction
    //! runtextmacro Endscope()

    public function SpellEffect takes Unit caster returns nothing
        local player casterOwner = caster.owner
        local unit casterSelf = caster.self
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = GetAttachedInteger(casterOwner, SuperCarrot_SCOPE_ID)
        local fogmodifier dummyFogModifier
        local unit dummyUnit
        local timer durationTimer
        set casterSelf = null
        call DestroyEffectWJ( AddSpecialEffectWJ( AREA_EFFECT_PATH, casterX, casterY ) )
        if ( d == NULL ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set dummyFogModifier = CreateFogModifierCircleWJ( casterOwner, FOG_OF_WAR_VISIBLE, CENTER_X, CENTER_Y, 99999, false, false )
            set dummyUnit = CreateUnitWJ( casterOwner, DUMMY_UNIT_ID, CENTER_X, CENTER_Y, 0 )
            set d.dummyFogModifier = dummyFogModifier
            set d.dummyUnit = dummyUnit
            set dummyUnit = null
            set d.durationTimer = durationTimer
            call AttachInteger( casterOwner, SuperCarrot_SCOPE_ID, d )
            call AttachInteger( durationTimer, SuperCarrot_SCOPE_ID, d )
            call FogModifierStart( dummyFogModifier )
            set dummyFogModifier = null
        else
            set durationTimer = d.durationTimer
        endif
        call TimerStart( durationTimer, DURATION, false, function Ending )
        set durationTimer = null
        call Effect_Effect_Start(casterOwner, casterX, casterY)
        set casterOwner = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 250)
        call SetItemTypeMaxCharges(d, 1)
        call SetItemTypeRefreshInterval(d, 45)
        call SetItemTypeRefreshIntervalStart(d, 200)

        call InitEffectType( AREA_EFFECT_PATH )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call Effect_Effect_Init()
    endfunction
//! runtextmacro Endscope()