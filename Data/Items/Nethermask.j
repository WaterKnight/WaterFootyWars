//TESH.scrollpos=81
//TESH.alwaysfold=0
//! runtextmacro Scope("Nethermask")
    globals
        public constant integer ITEM_ID = 'I00C'
        public constant integer SET_ITEM_ID = 'I027'

        private constant real BONUS_RELATIVE_MANA_REGENERATION = 0.4
    endglobals

    private struct Data
        real bonusManaRegeneration
    endstruct

    //! runtextmacro Scope("Use")
        globals
            public constant integer Use_SPELL_ID = 'A04F'

            private constant real Use_BONUS_RELATIVE_SPELL_ARMOR = 0.5
            private constant real Use_BONUS_RELATIVE_SPELL_DAMAGE = 0.5
            private constant string Use_CASTER_EFFECT_PATH = "Abilities\\Spells\\Human\\MagicSentry\\MagicSentryCaster.mdl"
            private constant string Use_CASTER_EFFECT_ATTACHMENT_POINT = "overhead"
            private constant real Use_DURATION = 15.
        endglobals

        private struct Use_Data
            Unit caster
            effect casterEffect
            timer durationTimer
        endstruct

        private function Use_Ending takes Unit caster, Use_Data d, timer durationTimer returns nothing
            local effect casterEffect = d.casterEffect
            local integer casterId = caster.id
            call d.destroy()
            call FlushAttachedIntegerById( casterId, Use_SCOPE_ID )
            //! runtextmacro RemoveEventById( "casterId", "Use_EVENT_DEATH" )
            call DestroyEffectWJ( casterEffect )
            set casterEffect = null
            call FlushAttachedInteger( durationTimer, Use_SCOPE_ID )
            call DestroyTimerWJ( durationTimer )
            call AddUnitArmorBySpellBonus( caster, -Use_BONUS_RELATIVE_SPELL_ARMOR )
            call AddUnitDamageBySpellBonus( caster, -Use_BONUS_RELATIVE_SPELL_DAMAGE )
        endfunction

        public function Use_Death takes Unit caster returns nothing
            local Use_Data d = GetAttachedIntegerById(caster.id, Nethermask_SCOPE_ID)
            if ( d != NULL ) then
                call Use_Ending( caster, d, d.durationTimer )
            endif
        endfunction

        private function Use_Death_Event takes nothing returns nothing
            call Use_Death( DYING_UNIT )
        endfunction

        private function Use_EndingByTimer takes nothing returns nothing
            local timer durationTimer = GetExpiredTimer()
            local Use_Data d = GetAttachedInteger(durationTimer, Use_SCOPE_ID)
            call Use_Ending( d.caster, d, durationTimer )
            set durationTimer = null
        endfunction

        public function Use_SpellEffect takes Unit caster returns nothing
            local integer casterId = caster.id
            local Use_Data d = GetAttachedIntegerById(casterId, Use_SCOPE_ID)
            local timer durationTimer
            local boolean isNew = (d == NULL)
            if ( isNew ) then
                set d = Use_Data.create()
                set durationTimer = CreateTimerWJ()
                set d.durationTimer = durationTimer
                set d.caster = caster
                call AttachIntegerById( casterId, Use_SCOPE_ID, d )
                //! runtextmacro AddEventById( "casterId", "Use_EVENT_DEATH" )
                call AttachInteger( durationTimer, Use_SCOPE_ID, d )
            else
                set durationTimer = d.durationTimer
                call DestroyEffectWJ( d.casterEffect )
            endif
            set d.casterEffect = AddSpecialEffectTargetWJ( Use_CASTER_EFFECT_PATH, caster.self, Use_CASTER_EFFECT_ATTACHMENT_POINT )
            if (isNew) then
                call AddUnitArmorBySpellBonus( caster, Use_BONUS_RELATIVE_SPELL_ARMOR )
                call AddUnitDamageBySpellBonus( caster, Use_BONUS_RELATIVE_SPELL_DAMAGE )
            else
            endif
            call TimerStart( durationTimer, Use_DURATION, false, function Use_EndingByTimer )
            set durationTimer = null
        endfunction

        private function Use_SpellEffect_Event takes nothing returns nothing
            call Use_SpellEffect( CASTER )
        endfunction

        public function Use_Init takes nothing returns nothing
            //! runtextmacro CreateEvent( "Use_EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Use_Death_Event" )
            call InitEffectType( Use_CASTER_EFFECT_PATH )
            call InitAbility( Use_SPELL_ID )
            //! runtextmacro AddNewEventById( "Use_EVENT_CAST", "Use_SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function Use_SpellEffect_Event" )
        endfunction
    //! runtextmacro Endscope()

    public function Drop takes Unit manipulatingUnit, Item mask returns nothing
        local integer maskId = mask.id
        local Data d = GetAttachedIntegerById(maskId, Nethermask_SCOPE_ID)
        local real bonusManaRegeneration = -d.bonusManaRegeneration
        call d.destroy()
        call FlushAttachedIntegerById(maskId, Nethermask_SCOPE_ID)
        call AddUnitManaRegenerationBonus(manipulatingUnit, bonusManaRegeneration)
    endfunction

    public function PickUp takes Unit manipulatingUnit, Item mask returns nothing
        local real bonusManaRegeneration = GetUnitManaRegeneration(manipulatingUnit) * BONUS_RELATIVE_MANA_REGENERATION
        local Data d = Data.create()
        set d.bonusManaRegeneration = bonusManaRegeneration
        call AttachIntegerById(mask.id, Nethermask_SCOPE_ID, d)
        call AddUnitManaRegenerationBonus(manipulatingUnit, bonusManaRegeneration)
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 900)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 900)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple(OrbOfWisdom_ITEM_ID, SET_ITEM_ID, ITEM_ID)

        call Use_Use_Init()
    endfunction
//! runtextmacro Endscope()