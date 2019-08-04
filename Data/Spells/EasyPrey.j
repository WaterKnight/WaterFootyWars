//TESH.scrollpos=141
//TESH.alwaysfold=0
//! runtextmacro Scope("EasyPrey")
    globals
        private constant integer ORDER_ID = 852583//OrderId( "doom" )
        public constant integer SPELL_ID = 'A01V'

        public constant integer ARROW_SPELL_ID = 'A049'

        private integer array BONUS_DROP
        private real array BONUS_RELATIVE_ARMOR
        private real array DAMAGE
        private real array DURATION
        private real array HERO_DURATION
        private constant integer LEVELS_AMOUNT = 5
        private constant string TARGET_EFFECT_PATH = "Abilities\\Spells\\Undead\\Curse\\CurseTarget.mdl"
        private constant string TARGET_EFFECT_ATTACHMENT_POINT = "overhead"
    endglobals

    private struct Data
        integer abilityLevel
        timer array durationTimer[LEVELS_AMOUNT]
        Unit target
        effect targetEffect
    endstruct

    private function Ending takes Data d, timer durationTimer, Unit target returns nothing
        local integer abilityLevel = d.abilityLevel
        local integer iteration = abilityLevel - 1
        local effect targetEffect
        local integer targetId = target.id
        loop
            exitwhen (durationTimer == d.durationTimer[iteration])
            set iteration = iteration - 1
        endloop
        set d.durationTimer[iteration] = null
        if ( abilityLevel - 1 <= iteration ) then
            loop
                exitwhen (iteration < 0)
                exitwhen (d.durationTimer[iteration] != null)
                set iteration = iteration - 1
            endloop
            if ( iteration > -1 ) then
                set d.abilityLevel = iteration + 1
                call AddUnitArmorRelativeBonus( target, BONUS_RELATIVE_ARMOR[iteration] - BONUS_RELATIVE_ARMOR[abilityLevel] )
                call AddUnitDropBonus( target, BONUS_DROP[iteration] - BONUS_DROP[abilityLevel] )
            else
                set targetEffect = d.targetEffect
                set targetId = target.id
                call d.destroy()
                call DestroyEffectWJ( targetEffect )
                set targetEffect = null
                call FlushAttachedIntegerById( targetId, EasyPrey_SCOPE_ID )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DISPEL" )
                call AddUnitArmorRelativeBonus( target,  -BONUS_RELATIVE_ARMOR[abilityLevel] )
                call AddUnitDropBonus( target, -BONUS_DROP[abilityLevel] )
            endif
        endif
        call FlushAttachedInteger( durationTimer, EasyPrey_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
    endfunction

    public function Dispel takes Unit target returns nothing
        local integer abilityLevel
        local Data d = GetAttachedIntegerById(target.id, EasyPrey_SCOPE_ID)
        local timer durationTimer
        local integer iteration
        if (d != NULL) then
            set abilityLevel = d.abilityLevel
            set iteration = 0
            loop
                set durationTimer = d.durationTimer[iteration]
                if ( durationTimer != null ) then
                    call Ending( d, durationTimer, target )
                endif
                set iteration = iteration + 1
                exitwhen ( iteration >= abilityLevel )
            endloop
            set durationTimer = null
        endif
    endfunction

    public function Death takes Unit target returns nothing
        call Dispel(target)
    endfunction

    private function Death_Event takes nothing returns nothing
        call Dispel( DYING_UNIT )
    endfunction

    private function Dispel_Event takes nothing returns nothing
        call Dispel( TRIGGER_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, EasyPrey_SCOPE_ID)
        call Ending( d, durationTimer, d.target )
        set durationTimer = null
    endfunction

    //! runtextmacro Scope("ManaRestoration")
        globals
            private real array MANA_COST
            private real array MANA_COST_RESTORATION_FACTOR_PER_INTELLIGENCE_POINT
        endglobals

        private struct ManaRestoration_Data
            real array manaCost[LEVELS_AMOUNT]
        endstruct

        public function ManaRestoration_Start takes integer abilityLevel, Unit caster, integer spellId returns nothing
            local ManaRestoration_Data d = GetAttachedIntegerById(spellId, ManaRestoration_SCOPE_ID)
            local real manaCost = d.manaCost[abilityLevel]
            call AddUnitState( caster.self, UNIT_STATE_MANA, ( 1 - Pow( MANA_COST_RESTORATION_FACTOR_PER_INTELLIGENCE_POINT[abilityLevel], GetHeroIntelligenceTotal( caster ) ) ) * manaCost )
        endfunction

        public function ManaRestoration_Init takes nothing returns nothing
            local ManaRestoration_Data d = ManaRestoration_Data.create()
            set d.manaCost[0] = 60
            set d.manaCost[1] = 55
            set d.manaCost[2] = 50
            set d.manaCost[3] = 50
            set d.manaCost[4] = 50
            call AttachIntegerById(SPELL_ID, ManaRestoration_SCOPE_ID, d)
            set d = ManaRestoration_Data.create()
            set d.manaCost[0] = 17
            set d.manaCost[1] = 17
            set d.manaCost[2] = 17
            set d.manaCost[3] = 17
            set d.manaCost[4] = 17
            call AttachIntegerById(ARROW_SPELL_ID, ManaRestoration_SCOPE_ID, d)
            set MANA_COST_RESTORATION_FACTOR_PER_INTELLIGENCE_POINT[1] = 0.99
            set MANA_COST_RESTORATION_FACTOR_PER_INTELLIGENCE_POINT[2] = 0.99
            set MANA_COST_RESTORATION_FACTOR_PER_INTELLIGENCE_POINT[3] = 0.99
            set MANA_COST_RESTORATION_FACTOR_PER_INTELLIGENCE_POINT[4] = 0.99
            set MANA_COST_RESTORATION_FACTOR_PER_INTELLIGENCE_POINT[5] = 0.99
        endfunction
    //! runtextmacro Endscope()

    private function Start takes integer abilityLevel, Unit caster, integer spellId, Unit target returns nothing
        local real duration
        local timer durationTimer
        local integer iteration
        local integer oldAbilityLevel
        local integer targetId = target.id
        local Data d = GetAttachedIntegerById(targetId, EasyPrey_SCOPE_ID)
        local boolean isNew = (d == NULL)
        local unit targetSelf = target.self
        if ( isNew ) then
            set d = Data.create()
            set durationTimer = CreateTimerWJ()
            set iteration = LEVELS_AMOUNT - 1
            set d.abilityLevel = abilityLevel
            set d.target = target
            loop
                if (iteration == abilityLevel - 1) then
                    set d.durationTimer[iteration] = durationTimer
                else
                    set d.durationTimer[iteration] = null
                endif
                set iteration = iteration - 1
                exitwhen (iteration < 0)
            endloop
            call AttachInteger(durationTimer, EasyPrey_SCOPE_ID, d)
            call AttachIntegerById(targetId, EasyPrey_SCOPE_ID, d)
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
            //! runtextmacro AddEventById( "targetId", "EVENT_DISPEL" )
        else
            set durationTimer = d.durationTimer[abilityLevel - 1]
            if (durationTimer == null) then
                set durationTimer = CreateTimerWJ()
                set d.durationTimer[abilityLevel - 1] = durationTimer
                call AttachInteger(durationTimer, EasyPrey_SCOPE_ID, d)
            endif
            set oldAbilityLevel = d.abilityLevel
            call DestroyEffectWJ( d.targetEffect )
        endif
        set d.targetEffect = AddSpecialEffectTargetWJ( TARGET_EFFECT_PATH, targetSelf, TARGET_EFFECT_ATTACHMENT_POINT )
        if ( isNew ) then
            call AddUnitArmorRelativeBonus( target, BONUS_RELATIVE_ARMOR[abilityLevel] )
            call AddUnitDropBonus( target, BONUS_DROP[abilityLevel] )
        elseif (abilityLevel >= oldAbilityLevel) then
            set d.abilityLevel = abilityLevel
            call AddUnitArmorRelativeBonus( target, BONUS_RELATIVE_ARMOR[abilityLevel] - BONUS_RELATIVE_ARMOR[oldAbilityLevel] )
            call AddUnitDropBonus( target, BONUS_DROP[abilityLevel] - BONUS_DROP[oldAbilityLevel] )
        endif
        if ( IsUnitType( targetSelf, UNIT_TYPE_HERO ) ) then
            set duration = HERO_DURATION[abilityLevel]
        else
            set duration = DURATION[abilityLevel]
        endif
        set targetSelf = null
        call TimerStart( durationTimer, duration, false, function EndingByTimer )
        set durationTimer = null
        call ManaRestoration_ManaRestoration_Start(abilityLevel, caster, spellId)
    endfunction

    public function SpellEffect takes integer abilityLevel, Unit caster, integer spellId, Unit target returns nothing
        call Start(abilityLevel, caster, spellId, target)
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( GetUnitAbilityLevel(CASTER.self, SPELL_ID), CASTER, SPELL_ID, TARGET_UNIT )
    endfunction

    public function Order takes unit target returns string
        if ( IsUnitType( target, UNIT_TYPE_MECHANICAL ) ) then
            return ErrorStrings_NOT_MECHANICAL
        endif
        if ( IsUnitType( target, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        return null
    endfunction

    private function Order_Event takes nothing returns nothing
        set ERROR_MSG = Order( TARGET_UNIT.self )
    endfunction

    //! runtextmacro Scope("Arrow")
        globals
            private integer array Arrow_BUFF_ID
            private constant integer Arrow_ORDER_ID = 852243//OrderId( "coldarrowstarg" )
        endglobals

        private struct Arrow_Data
        endstruct

        public function Arrow_Damage takes Unit caster, real damageAmount, Unit target returns real
            local integer currentBuffId
            local integer iteration = LEVELS_AMOUNT - 1
            local unit targetSelf = target.self
            loop
                set currentBuffId = Arrow_BUFF_ID[iteration]
                exitwhen ( GetUnitAbilityLevel( targetSelf, currentBuffId ) > 0 )
                set iteration = iteration - 1
                exitwhen ( iteration < 1 )
            endloop
            if ( iteration > 0 ) then
                set damageAmount = damageAmount + DAMAGE[iteration]
                call UnitRemoveAbility( targetSelf, currentBuffId )
                call Start( iteration, caster, ARROW_SPELL_ID, target )
            endif
            set targetSelf = null
            return damageAmount
        endfunction

        private function Arrow_Damage_Event takes nothing returns nothing
            set DAMAGE_AMOUNT = Arrow_Damage( DAMAGE_SOURCE, DAMAGE_AMOUNT, TRIGGER_UNIT )
        endfunction

        public function Arrow_Order takes unit target returns string
            return Order( target )
        endfunction

        private function Arrow_Order_Event takes nothing returns nothing
            set ERROR_MSG = Arrow_Order( TARGET_UNIT.self )
        endfunction

        public function Arrow_Learn takes Unit caster returns nothing
            local integer casterId = caster.id
            local Arrow_Data d = GetAttachedIntegerById(casterId, Arrow_SCOPE_ID)
            if ( d == NULL ) then
                call AttachIntegerById(casterId, Arrow_SCOPE_ID, Arrow_Data.create())
                //! runtextmacro AddEventById( "casterId", "Arrow_EVENT_DAMAGE" )
            endif
        endfunction

        private function Arrow_Learn_Event takes nothing returns nothing
            call Arrow_Learn( LEARNER )
        endfunction

        public function Arrow_Init takes nothing returns nothing
            set Arrow_BUFF_ID[1] = 'B00L'
            set Arrow_BUFF_ID[2] = 'B00M'
            set Arrow_BUFF_ID[3] = 'B00N'
            set Arrow_BUFF_ID[4] = 'B00O'
            set Arrow_BUFF_ID[5] = 'B00P'
            //! runtextmacro CreateEvent( "Arrow_EVENT_DAMAGE", "UnitTakesDamage_EVENT_KEY_FOR_DAMAGE_AS_DAMAGE_SOURCE", "0", "function Arrow_Damage_Event" )
            call AddOrderAbility( Arrow_ORDER_ID, ARROW_SPELL_ID )
            call InitAbility( ARROW_SPELL_ID )
            //! runtextmacro AddNewEventById( "Arrow_EVENT_ORDER", "GetAbilityOrderId( ARROW_SPELL_ID, Arrow_ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Arrow_Order_Event" )
            //! runtextmacro AddNewEventById( "Arrow_EVENT_LEARN", "ARROW_SPELL_ID", "UnitLearnsSkill_EVENT_KEY", "0", "function Arrow_Learn_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Init takes nothing returns nothing
        set BONUS_DROP[1] = 20
        set BONUS_DROP[2] = 24
        set BONUS_DROP[3] = 28
        set BONUS_DROP[4] = 32
        set BONUS_DROP[5] = 36
        set BONUS_RELATIVE_ARMOR[1] = -0.15
        set BONUS_RELATIVE_ARMOR[2] = -0.2
        set BONUS_RELATIVE_ARMOR[3] = -0.25
        set BONUS_RELATIVE_ARMOR[4] = -0.3
        set BONUS_RELATIVE_ARMOR[5] = -0.35
        set DAMAGE[1] = 3
        set DAMAGE[2] = 4
        set DAMAGE[3] = 5
        set DAMAGE[4] = 6
        set DAMAGE[5] = 7
        set DURATION[1] = 7
        set DURATION[2] = 8
        set DURATION[3] = 9
        set DURATION[4] = 10
        set DURATION[5] = 11
        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        //! runtextmacro CreateEvent( "EVENT_DISPEL", "UnitIsDispelled_EVENT_KEY_NEGATIVE", "0", "function Dispel_Event" )
        set HERO_DURATION[1] = 4
        set HERO_DURATION[2] = 4
        set HERO_DURATION[3] = 4
        set HERO_DURATION[4] = 4
        set HERO_DURATION[5] = 4
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_ORDER", "GetAbilityOrderId( SPELL_ID, ORDER_ID )", "UnitGetsOrder_EVENT_KEY", "0", "function Order_Event" )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
        call InitEffectType( TARGET_EFFECT_PATH )
        call Arrow_Arrow_Init()
        call ManaRestoration_ManaRestoration_Init()
    endfunction
//! runtextmacro Endscope()