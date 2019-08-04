//TESH.scrollpos=36
//TESH.alwaysfold=0
//! runtextmacro Scope("TonelessMist")
    globals
        private constant integer ORDER_ID = 852592//OrderId( "silence" )
        public constant integer SPELL_ID = 'A01T'

        private real array AREA_RANGE
        private real array DURATION
    endglobals

    private function Target_Ending takes integer Target returns nothing
        local integer TargetEffect = GetAttachedInteger( TonelessMist_Id(), "TargetEffect" )
        local integer TargetGroup = GetAttachedInteger( TonelessMist_Id(), "TargetGroup" )
        call FlushAttachedInteger( Target, "TonelessMist_TargetEffect" )
        call DestroyEffectWJ( TargetEffect )
        call GroupRemoveUnitWJ( TargetGroup, Target )
        call RemoveEvent( Target, UnitDies_EVENT_KEY, 0, GetAttachedInteger( TonelessMist_Id(), "EventDeath" ) )
        call AddUnitSilence( Target, -1 )
    endfunction

    public function Target_Death takes integer DyingUnit returns nothing
        local integer TargetGroup = GetAttachedInteger( TonelessMist_Id(), "TargetGroup" )
        if ( IsUnitInGroupWJ( DyingUnit, TargetGroup ) ) then
            call Target_Ending( DyingUnit )
        endif
    endfunction

    private function Target_Death_Event takes nothing returns nothing
        call Target_Death( DYING_UNIT )
    endfunction

    private function TargetConditions takes nothing returns boolean
        set filterUnit = GetFilterUnit()
        if ( GetUnitState( filterUnit, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( filterUnit, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitType( filterUnit, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        return true
    endfunction

    private function Update takes nothing returns nothing
        local integer AbilityLevel
        local integer CasterGroup = GetAttachedInteger( TonelessMist_Id(), "CasterGroup" )
        local integer Caster
        local integer DurationTimer
        local integer EnumGroup
        local integer EnumUnit
        local integer FertilizerAbilityLevel
        local integer FirstUnit = FirstOfGroupWJ( CasterGroup )
        local integer TargetGroup = GetAttachedInteger( TonelessMist_Id(), "TargetGroup" )
        set TEMP_PLAYER = GetOwningPlayer(caster)
        if ( FirstUnit == Null() ) then
            set EnumUnit = FirstUnit
            loop
                call GroupRemoveUnitWJ( CasterGroup, EnumUnit )
                call GroupAddUnitWJ( CasterGroup, EnumUnit )
                set AbilityLevel = GetAttachedInteger( DurationTimer, "AbilityLevel" )
                set Caster = GetAttachedInteger( DurationTimer, "Caster" )
                set FertilizerAbilityLevel = GetUnitAbilityLevelWJ( Caster, Fertilizer_Id() )
                call GroupEnumUnitsInRangeWithCollision( EnumGroup, GetUnitXWJ( Caster ), GetUnitYWJ( Caster ), GetAttachedReal( TonelessMist_Id(), "AreaRange" + I2S( AbilityLevel ) ) + GetAttachedReal( Fertilizer_Id(), "TonelessMist_BonusAreaRange" + I2S( FertilizerAbilityLevel ) ), GetAttachedInteger( TonelessMist_Id(), "TargetConditions" ) )
                set EnumUnit = FirstOfGroupWJ( CasterGroup )
                exitwhen ( ( EnumUnit == FirstUnit ) or ( EnumUnit == Null() ) )
            endloop
        endif
        set FirstUnit = FirstOfGroupWJ( TargetGroup )
        if ( FirstUnit != Null() ) then
            set EnumUnit = FirstUnit
            loop
                call GroupRemoveUnitWJ( TargetGroup, EnumUnit )
                if ( IsUnitInGroupWJ( EnumUnit, EnumUnit ) ) then
                    call GroupAddUnitWJ( TargetGroup, EnumUnit )
                    call GroupRemoveUnitWJ( EnumGroup, EnumUnit )
                else
                    call TonelessMist_Target_Ending( EnumUnit )
                endif
                set EnumUnit = FirstOfGroupWJ( TargetGroup )
                exitwhen ( ( EnumUnit == FirstUnit ) or ( EnumUnit == Null() ) )
            endloop
        endif
        loop
            set EnumUnit = FirstOfGroupWJ( EnumGroup )
            exitwhen ( EnumUnit == Null() )
            call GroupRemoveUnitWJ( EnumGroup, EnumUnit )
            call GroupAddUnitWJ( TargetGroup, EnumUnit )
            call AttachInteger( EnumUnit, "TargetEffect", AddSpecialEffectTargetWJ( GetAttachedString( TonelessMist_Id(), "GraphicTarget" ), EnumUnit, GetAttachedString( TonelessMist_Id(), "GraphicTargetAttachmentPoint" ) ) )
            call AddEvent( EnumUnit, UnitDies_EVENT_KEY, 0, GetAttachedInteger( TonelessMist_Id(), "EventDeath" ) )
            call AddUnitSilence( EnumUnit, 1 )
        endloop
    endfunction

    private function Caster_Ending takes integer DurationTimer returns nothing
        local integer CasterGroup = GetAttachedInteger( TonelessMist_Id(), "CasterGroup" )
        local integer Caster = GetAttachedInteger( DurationTimer, "Caster" )
        local integer GraphicCaster = GetAttachedInteger( DurationTimer, "GraphicCaster" )
        call FlushAttachedInteger( Caster, "TonelessMist_DurationTimer" )
        call FlushAttachedInteger( DurationTimer, "AbilityLevel" )
        call FlushAttachedInteger( DurationTimer, "Caster" )
        call FlushAttachedInteger( DurationTimer, "GraphicCaster" )
        call FlushAttachedInteger( DurationTimer, "UpdateTimer" )
        call DestroyTimerWJ( DurationTimer )
        call GroupRemoveUnitWJ( CasterGroup, Caster )
        if ( FirstOfGroupWJ( CasterGroup ) == Null() ) then
            call PauseTimerWJ( GetAttachedInteger( TonelessMist_Id(), "UpdateTimer" ) )
        else
            call Update()
        endif
    endfunction

    public function Caster_Death takes integer DyingUnit returns nothing
        local integer DurationTimer = GetAttachedInteger( DyingUnit, "DurationTimer" )
        if ( DurationTimer != Null() ) then
            call Caster_Ending( DurationTimer )
        endif
    endfunction

    private function Caster_Death_Event takes nothing returns nothing
        call Caster_Death( DYING_UNIT )
    endfunction

    private function EndingByTimer takes nothing returns nothing
        local integer DurationTimer = GetExpiredTimerWJ()
        call Caster_Ending( DurationTimer )
    endfunction

    public function SpellEffect takes integer Caster returns nothing
        local integer AbilityLevel = GetUnitAbilityLevelWJ( Caster, TonelessMist_Id() )
        local integer CasterGroup = GetAttachedInteger( TonelessMist_Id(), "CasterGroup" )
        local integer DurationTimer = GetAttachedInteger( Caster, "Frenzy_DurationTimer" )
        if ( DurationTimer == Null() ) then
            set DurationTimer = CreateTimerWJ()
            call AttachInteger( Caster, "TonelessMist_DurationTimer", DurationTimer )
            call AttachInteger( DurationTimer, "AbilityLevel", AbilityLevel )
            call AttachInteger( DurationTimer, "Caster", Caster )
            call AttachInteger( DurationTimer, "GraphicCaster", AddSpecialEffectTargetWJ( GetAttachedString( TonelessMist_Id(), "GraphicCaster" ), Caster, GetAttachedString( TonelessMist_Id(), "GraphicCasterAttachmentPoint" ) ) )
            call GroupAddUnitWJ( CasterGroup, Caster )
            call TonelessMist_Update()
            call TimerStartWJ( GetAttachedInteger( TonelessMist_Id(), "UpdateTimer" ), GetAttachedReal( TonelessMist_Id(), "UpdateTime" ), true, function Update )
        endif
        call TimerStartWJ( DurationTimer, GetAttachedReal( TonelessMist_Id(), "Duration" + I2S( AbilityLevel ) ), false, function EndingByTimer )
    endfunction

    public function Init takes nothing returns nothing
        set AREA_RANGE[1] = 400
        set AREA_RANGE[2] = 400
        set DURATION[1] = 30
        set DURATION[2] = 30
        call AttachInteger( TonelessMist_Id(), "CasterGroup", CreateGroupWJ() )
        set ENUM_GROUP = CreateGroupWJ()
        call AttachInteger( TonelessMist_Id(), "EventCasterDeath", CreateEvent( function Caster_Death_Event ) )
        call AttachInteger( TonelessMist_Id(), "EventTargetDeath", CreateEvent( function Target_Death_Event ) )
        call AttachString( TonelessMist_Id(), "GraphicCaster", "Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl" )
        call AttachString( TonelessMist_Id(), "GraphicCasterAttachmentPoint", "Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl" )
        call AttachString( TonelessMist_Id(), "GraphicTarget", "Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl" )
        call AttachString( TonelessMist_Id(), "GraphicTargetAttachmentPoint", "overhead" )
        call AttachInteger( TonelessMist_Id(), "TargetConditions", ConditionWJ( function TargetConditions ) )
        call AttachInteger( TonelessMist_Id(), "TargetGroup", CreateGroupWJ() )
        call AttachReal( TonelessMist_Id(), "UpdateTime", 0.5 )
        call AttachInteger( TonelessMist_Id(), "UpdateTimer", CreateTimerWJ() )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
    endfunction
//! runtextmacro Endscope()