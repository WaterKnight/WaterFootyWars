//TESH.scrollpos=203
//TESH.alwaysfold=0
//! runtextmacro Scope("MightyHammer")
    globals
        public constant integer ITEM_ID = 'I002'
        public constant integer SET_ITEM_ID = 'I01Z'
        public constant integer SPELL_ID = 'A04D'

        private constant real BONUS_STRENGTH = 10.
        private constant real DAMAGE_PER_ATTRIBUTE_POINT = 1.5
        private constant integer DUMMY_UNIT_ID = 'h00T'
        private constant real SPEED = 600.
        private constant real UPDATE_TIME = 0.035
        private constant real LENGTH = SPEED * UPDATE_TIME
    endglobals

    private struct Data
        Unit caster
        real damageAmount
        unit dummyUnit
        timer moveTimer
        Unit target
        real targetX
        real targetY
        real targetZ
        real x
        real y
        real z
    endstruct

    private function Ending takes Data d, boolean isTargetNotNull, unit dummyUnit, timer moveTimer, Unit target returns nothing
        local integer targetId
        call d.destroy()
        call SetUnitAnimationByIndex( dummyUnit, 1 )
        call RemoveUnitTimed( dummyUnit, 2 )
        call FlushAttachedInteger( moveTimer, MightyHammer_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        if ( isTargetNotNull ) then
            set targetId = target.id
            call RemoveIntegerFromTableById( targetId, MightyHammer_SCOPE_ID, d )
            if ( CountIntegersInTableById( targetId, MightyHammer_SCOPE_ID ) == TABLE_EMPTY ) then
                //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
            endif
        endif
    endfunction

    private function Death_ResetTarget takes Data d, Unit target, real targetX, real targetY, real targetZ returns nothing
        local integer targetId = target.id
        call RemoveIntegerFromTableById( targetId, MightyHammer_SCOPE_ID, d )
        set d.target = NULL
        if ( CountIntegersInTableById( targetId, MightyHammer_SCOPE_ID ) == TABLE_EMPTY ) then
            //! runtextmacro RemoveEventById( "targetId", "EVENT_DEATH" )
        endif
        set d.targetX = targetX
        set d.targetY = targetY
        set d.targetZ = targetZ
    endfunction

    public function Death takes Unit target, real targetX, real targetY, real targetZ returns nothing
        local Data d
        local integer targetId = target.id
        local integer iteration = CountIntegersInTableById( targetId, MightyHammer_SCOPE_ID )
        if ( iteration > TABLE_EMPTY ) then
            loop
                set d = GetIntegerFromTableById( targetId, MightyHammer_SCOPE_ID, iteration )
                call Death_ResetTarget( d, target, targetX, targetY, targetZ )
                set iteration = iteration - 1
                exitwhen ( iteration < TABLE_STARTED )
            endloop
        endif
    endfunction

    private function Death_Event takes nothing returns nothing
        local unit dyingUnitSelf = DYING_UNIT.self
        local real dyingUnitX = GetUnitX(dyingUnitSelf)
        local real dyingUnitY = GetUnitY(dyingUnitSelf)
        call Death( DYING_UNIT, dyingUnitX, dyingUnitY, GetUnitZ(dyingUnitSelf, dyingUnitX, dyingUnitY) )
        set dyingUnitSelf = null
    endfunction

    private function TargetConditions takes player casterOwner, Unit target returns string
        set TEMP_UNIT_SELF = target.self
        if ( IsUnitAlly( TEMP_UNIT_SELF, casterOwner ) ) then
            return ErrorStrings_NOT_ALLY
        endif
        if ( IsUnitType( TEMP_UNIT_SELF, UNIT_TYPE_STRUCTURE ) ) then
            return ErrorStrings_NOT_STRUCTURE
        endif
        if ( GetUnitInvulnerability( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_INVULNERABLE
        endif
        if ( GetUnitMagicImmunity( target ) > 0 ) then
            return ErrorStrings_TARGET_IS_MAGIC_IMMUNE
        endif
        return null
    endfunction

    private function Move takes nothing returns nothing
        local real angleLengthXYZ
        local real angleXY
        local Unit caster
        local real damageAmount
        local real distanceX
        local real distanceY
        local real distanceZ
        local boolean isTargetNotNull
        local real lengthXY
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, MightyHammer_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local real dummyUnitX = d.x
        local real dummyUnitY = d.y
        local real dummyUnitZ = d.z
        local boolean reachesTarget
        local Unit target = d.target
        local boolean isTargetNull = ( target == null )
        local unit targetSelf
        local real targetX
        local real targetY
        local real targetZ
        if ( isTargetNull ) then
            set targetX = d.targetX
            set targetY = d.targetY
            set targetZ = d.targetZ
        else
            set targetSelf = target.self
            set targetX = GetUnitX( targetSelf )
            set targetY = GetUnitY( targetSelf )
            set targetZ = GetUnitZ( targetSelf, targetX, targetY ) + GetUnitImpactZ(target)
            set targetSelf = null
        endif
        set reachesTarget = ( DistanceByCoordinatesWithZ( dummyUnitX, dummyUnitY, dummyUnitZ, targetX, targetY, targetZ ) <= LENGTH )
        if ( reachesTarget ) then
            set dummyUnitX = targetX
            set dummyUnitY = targetY
            set dummyUnitZ = targetZ
        else
            set distanceZ = targetZ - dummyUnitZ
            set angleLengthXYZ = Atan2( distanceZ, DistanceByCoordinates( dummyUnitX, dummyUnitY, targetX, targetY ) )
            set distanceX = targetX - dummyUnitX
            set distanceY = targetY - dummyUnitY
            set angleXY = Atan2( distanceY, distanceX )
            set lengthXY = LENGTH * Cos( angleLengthXYZ )
            set dummyUnitX = dummyUnitX + lengthXY * Cos( angleXY )
            set dummyUnitY = dummyUnitY + lengthXY * Sin( angleXY )
            set dummyUnitZ = dummyUnitZ + LENGTH * Sin( angleLengthXYZ )
            call SetUnitFacingWJ( dummyUnit, angleXY )
        endif
        call SetUnitX( dummyUnit, dummyUnitX )
        call SetUnitY( dummyUnit, dummyUnitY )
        call SetUnitZ( dummyUnit, dummyUnitX, dummyUnitY, dummyUnitZ )
        if ( reachesTarget ) then
            set isTargetNotNull = ( isTargetNull == false )
            if ( isTargetNotNull ) then
                set damageAmount = d.damageAmount
            endif
            call Ending( d, isTargetNotNull, dummyUnit, moveTimer, target )
            if ( isTargetNotNull ) then
                if ( TargetConditions( caster.owner, target ) == null ) then
                    call UnitDamageUnitBySpell( caster, target, damageAmount )
                endif
            endif
        else
            set d.x = dummyUnitX
            set d.y = dummyUnitY
            set d.z = dummyUnitZ
        endif
        set moveTimer = null
    endfunction

    public function SpellEffect takes Unit caster, Unit target returns nothing
        local unit casterSelf = caster.self
        local real casterX = GetUnitX(casterSelf)
        local real casterY = GetUnitY(casterSelf)
        local real casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
        local Data d = Data.create()
        local unit dummyUnit = CreateUnitWJ( caster.owner, DUMMY_UNIT_ID, casterX, casterY, GetUnitFacingWJ( casterSelf ) )
        local timer moveTimer = CreateTimer()
        local integer targetId = target.id
        set casterSelf = null
        set d.caster = caster
        set d.damageAmount = ( GetHeroAgilityTotal( caster ) + GetHeroIntelligenceTotal( caster ) + GetHeroStrengthTotal( caster ) ) * DAMAGE_PER_ATTRIBUTE_POINT
        set d.dummyUnit = dummyUnit
        set d.moveTimer = moveTimer
        set d.target = target
        set d.x = casterX
        set d.y = casterY
        set d.z = casterZ
        call AttachInteger( moveTimer, MightyHammer_SCOPE_ID, d )
        call AddIntegerToTableById( targetId, MightyHammer_SCOPE_ID, d )
        if ( CountIntegersInTableById( targetId, MightyHammer_SCOPE_ID ) == TABLE_STARTED ) then
            //! runtextmacro AddEventById( "targetId", "EVENT_DEATH" )
        endif
        call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
        set dummyUnit = null
        call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
        set moveTimer = null
    endfunction

    private function SpellEffect_Event takes nothing returns nothing
        call SpellEffect( CASTER, TARGET_UNIT )
    endfunction

    public function Drop takes Unit manipulatingUnit returns nothing
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, -BONUS_STRENGTH )
    endfunction

    public function PickUp takes Unit manipulatingUnit returns nothing
        call AddHeroStrengthBonus( manipulatingUnit, manipulatingUnit.type, BONUS_STRENGTH )
    endfunction

    public function Init takes nothing returns nothing
        local ItemType d = InitItemTypeEx(ITEM_ID)
        call SetItemTypeGoldCost(d, 1000)

        set d = InitItemTypeEx(SET_ITEM_ID)
        call SetItemTypeGoldCost(d, 1000)
        call SetItemTypeMaxCharges(d, 1)

        call CreateSetSimple(GiantAxe_ITEM_ID, SET_ITEM_ID, ITEM_ID)

        //! runtextmacro CreateEvent( "EVENT_DEATH", "UnitDies_EVENT_KEY", "0", "function Death_Event" )
        call InitUnitType( DUMMY_UNIT_ID )
        call InitAbility( SPELL_ID )
        //! runtextmacro AddNewEventById( "EVENT_CAST", "SPELL_ID", "UnitStartsEffectOfAbility_EVENT_KEY", "0", "function SpellEffect_Event" )
    endfunction
//! runtextmacro Endscope()