//TESH.scrollpos=205
//TESH.alwaysfold=0
//! runtextmacro Scope("FrostNova")
    globals
        private constant integer ORDER_ID = 852226//OrderId( "frostnova" )
        public constant integer SPELL_ID = 'A02R'

        private real array AREA_RANGE
        private integer array BLOCKS_AMOUNT
        private real array DAMAGE
        private constant integer DUMMY_UNIT_ID = 'n029'
        private real array DURATION
        private group ENUM_GROUP
        private constant real HIT_RANGE = 128.
        private constant integer LEVELS_AMOUNT = 5
        private constant integer MAX_BLOCKS_AMOUNT = 8
        private constant real SPEED = 300
        private real array STUN_DURATION
        private real array STUN_HERO_DURATION
        private boolexpr TARGET_CONDITIONS
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        integer abilityLevel
        unit array blocks[MAX_BLOCKS_AMOUNT]
        Unit caster
        real array lengthX[MAX_BLOCKS_AMOUNT]
        real array lengthY[MAX_BLOCKS_AMOUNT]
        timer moveTimer
        group targetGroup
        real array x[MAX_BLOCKS_AMOUNT]
        real array y[MAX_BLOCKS_AMOUNT]
    endstruct

    private function Ending takes nothing returns nothing
        local unit array blocks
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, FrostNova_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local integer iteration = BLOCKS_AMOUNT[abilityLevel] - 1
        local timer moveTimer = d.moveTimer
        loop
            set blocks[iteration] = d.blocks[iteration]
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set iteration = BLOCKS_AMOUNT[abilityLevel] - 1
        call d.destroy()
        loop
            call RemoveUnitTimed( blocks[iteration], 1 )
            set blocks[iteration] = null
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        call FlushAttachedInteger( durationTimer, FrostNova_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( moveTimer, FrostNova_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        set moveTimer = null
    endfunction

    private function TargetConditions takes nothing returns boolean
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) ) then
            return false
        endif
        if ( IsUnitInGroup( FILTER_UNIT_SELF, TEMP_GROUP ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_MECHANICAL ) ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return false
        endif
        set FILTER_UNIT = GetUnit(FILTER_UNIT_SELF)
        if ( GetUnitInvulnerability( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( GetUnitMagicImmunity( FILTER_UNIT ) > 0 ) then
            return false
        endif
        if ( IsUnitWard( FILTER_UNIT ) ) then
            return false
        endif
        return true
    endfunction

    private function Move takes nothing returns nothing
        local unit block
        local Unit enumUnit
        local unit enumUnitSelf
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, FrostNova_SCOPE_ID)
        local integer abilityLevel = d.abilityLevel
        local Unit caster = d.caster
        local player casterOwner = caster.owner
        local real damageAmount = DAMAGE[abilityLevel]
        local real stunTime
        local group targetGroup = d.targetGroup
        local integer iteration = BLOCKS_AMOUNT[abilityLevel] - 1
        local real x
        local real y
        set moveTimer = null
        loop
            set block = d.blocks[iteration]
            set x = d.x[iteration] + d.lengthX[iteration]
            set y = d.y[iteration] + d.lengthY[iteration]
            set d.x[iteration] = x
            set d.y[iteration] = y
            call SetUnitXWJ( block, x )
            call SetUnitYWJ( block, y )
            set TEMP_GROUP = targetGroup
            set TEMP_PLAYER = casterOwner
            call GroupEnumUnitsInRangeWithCollision( ENUM_GROUP, x, y, HIT_RANGE, TARGET_CONDITIONS )
            set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
            if (enumUnitSelf != null) then
                loop
                    set enumUnit = GetUnit(enumUnitSelf)
                    call GroupRemoveUnit( ENUM_GROUP, enumUnitSelf )
                    call GroupAddUnit( targetGroup, enumUnitSelf )
                    if ( IsUnitType( enumUnitSelf, UNIT_TYPE_HERO ) ) then
                        set stunTime = STUN_HERO_DURATION[abilityLevel]
                    else
                        set stunTime = STUN_DURATION[abilityLevel]
                    endif
                    call SetUnitStunTimed( enumUnit, 2, stunTime )
                    call UnitDamageUnitBySpell( caster, enumUnit, damageAmount )
                    set enumUnitSelf = FirstOfGroup( ENUM_GROUP )
                    exitwhen ( enumUnitSelf == null )
                endloop
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set block = null
        set casterOwner = null
        set targetGroup = null
    endfunction

    public function SpellEffect takes Unit caster returns nothing
        local unit block
        local player casterOwner = caster.owner
        local unit casterSelf = caster.self
        local integer abilityLevel = GetUnitAbilityLevel( casterSelf, SPELL_ID )
        local real angle = GetUnitFacingWJ( casterSelf ) + PI / 4
        local integer blocksAmount = BLOCKS_AMOUNT[abilityLevel]
        local real angleAdd = 2 * PI / blocksAmount
        local real casterX = GetUnitX( casterSelf )
        local real casterY = GetUnitY( casterSelf )
        local Data d = Data.create()
        local timer durationTimer = CreateTimerWJ()
        local integer iteration = 0
        local timer moveTimer = CreateTimerWJ()
        set casterSelf = null
        set d.abilityLevel = abilityLevel
        loop
            set block = CreateUnitWJ( casterOwner, DUMMY_UNIT_ID, casterX, casterY, angle )
            set d.blocks[iteration] = block
            set d.lengthX[iteration] = LENGTH * Cos( angle )
            set d.lengthY[iteration] = LENGTH * Sin( angle )
            set d.x[iteration] = casterX
            set d.y[iteration] = casterY
            call SetUnitVertexColor( block, 255, 255, 255, 127 )
            set iteration = iteration + 1
            exitwhen ( iteration >= blocksAmount )
        endloop
        set casterOwner = null
        set d.caster = caster
        set d.moveTimer = moveTimer
        set d.targetGroup = CreateGroupWJ()
        call AttachInteger( durationTimer, FrostNova_SCOPE_ID, d )
        call AttachInteger( moveTimer, FrostNova_SCOPE_ID, d )
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
        call TimerStart( durationTimer, DURATION[abilityLevel], false, function Ending )
        set durationTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER )
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = LEVELS_AMOUNT
        set AREA_RANGE[1] = 450
        set AREA_RANGE[2] = 450
        set AREA_RANGE[3] = 450
        set AREA_RANGE[4] = 450
        set AREA_RANGE[5] = 450
        set BLOCKS_AMOUNT[1] = 5
        set BLOCKS_AMOUNT[2] = 6
        set BLOCKS_AMOUNT[3] = 7
        set BLOCKS_AMOUNT[4] = 8
        set BLOCKS_AMOUNT[5] = 8
        set DAMAGE[1] = 20
        set DAMAGE[2] = 20
        set DAMAGE[3] = 40
        set DAMAGE[4] = 60
        set DAMAGE[5] = 80
        loop
            set DURATION[iteration] = AREA_RANGE[iteration] / SPEED
            set iteration = iteration - 1
            exitwhen (iteration < 1)
        endloop
        set ENUM_GROUP = CreateGroupWJ()
        set STUN_DURATION[1] = 4
        set STUN_DURATION[2] = 6
        set STUN_DURATION[3] = 8
        set STUN_DURATION[4] = 9
        set STUN_DURATION[5] = 10
        set STUN_HERO_DURATION[1] = 1
        set STUN_HERO_DURATION[2] = 1
        set STUN_HERO_DURATION[3] = 1.5
        set STUN_HERO_DURATION[4] = 1.5
        set STUN_HERO_DURATION[5] = 2
        set TARGET_CONDITIONS = ConditionWJ( function TargetConditions )
        call InitUnitType( DUMMY_UNIT_ID )
        call AddOrderAbility( ORDER_ID, SPELL_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()