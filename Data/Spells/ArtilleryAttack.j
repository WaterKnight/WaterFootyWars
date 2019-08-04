//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("ArtilleryAttack")
    globals
        public constant integer SPELL_ID = 'A03Z'

        private constant real UPDATE_TIME = 0.01
    endglobals

    private struct Data
        Unit caster
        unit dummyUnit
        timer durationTimer
        real lengthX
        real lengthY
        real lengthZ
        real lengthZAdd
        timer moveTimer
        real targetX
        real targetY
        real x
        real y
        real z
    endstruct

    private function Impact takes Unit caster, unit dummyUnit, real targetX, real targetY returns nothing
        call SetUnitX( dummyUnit, targetX )
        call SetUnitY( dummyUnit, targetY )
        call SetUnitAnimation( dummyUnit, "death" )
        call RemoveUnitTimed( dummyUnit, 2 )
        set TARGET_X = targetX
        set TARGET_Y = targetY
        set TRIGGER_UNIT = caster
        call RunTrigger(UnitTakesDamage_ArtilleryAttack_ArtilleryAttack_DUMMY_TRIGGER)
    endfunction

    private function Ending takes nothing returns nothing
        local timer durationTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(durationTimer, ArtilleryAttack_SCOPE_ID)
        local Unit caster = d.caster
        local unit dummyUnit = d.dummyUnit
        local timer moveTimer = d.moveTimer
        local real targetX = d.targetX
        local real targetY = d.targetY
        call d.destroy()
        call FlushAttachedInteger( durationTimer, ArtilleryAttack_SCOPE_ID )
        call DestroyTimerWJ( durationTimer )
        set durationTimer = null
        call FlushAttachedInteger( moveTimer, ArtilleryAttack_SCOPE_ID )
        call DestroyTimerWJ( moveTimer )
        set moveTimer = null
        call Impact( caster, dummyUnit, targetX, targetY )
        set dummyUnit = null
        call RemoveUnitRemainingReference( caster )
    endfunction

    private function Move takes nothing returns nothing
        local timer moveTimer = GetExpiredTimer()
        local Data d = GetAttachedInteger(moveTimer, ArtilleryAttack_SCOPE_ID)
        local unit dummyUnit = d.dummyUnit
        local real lengthZ = d.lengthZ + d.lengthZAdd
        local real x = d.x + d.lengthX
        local real y = d.y + d.lengthY
        local real z = d.z + d.lengthZ
        set moveTimer = null
        set d.lengthZ = lengthZ
        set d.x = x
        set d.y = y
        set d.z = z
        call SetUnitX( dummyUnit, x )
        call SetUnitY( dummyUnit, y )
        call SetUnitZ( dummyUnit, x, y, z )
        set dummyUnit = null
    endfunction

    public function Damage takes Unit caster, Unit target returns nothing
        local real angleXYZ
        local unit casterSelf = caster.self
        local real casterTargetAngle
        local UnitType casterType
        local real casterX
        local real casterY
        local real casterZ
        local Data d
        local real distance
        local real distanceX
        local real distanceY
        local unit dummyUnit
        local real duration
        local timer durationTimer
        local real length
        local real lengthX
        local real lengthY
        local real lengthZ
        local real lengthZAdd
        local timer moveTimer
        local unit targetSelf
        local real targetX
        local real targetY
        local integer wavesAmount
        if ( GetUnitAbilityLevel( casterSelf, SPELL_ID ) > 0 ) then
            set casterType = caster.type
            set casterX = GetUnitX( casterSelf )
            set casterY = GetUnitY( casterSelf )
            set targetSelf = target.self
            set targetX = GetUnitX( targetSelf )
            set distanceX = targetX - casterX
            set targetY = GetUnitY( targetSelf )
            set targetSelf = null
            set distanceY = targetY - casterY
            set casterTargetAngle = Atan2( distanceY, distanceX )
            set dummyUnit = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, GetUnitTypeMissileDummyUnitId(casterType), casterX, casterY, casterTargetAngle )
            if ( ( casterX != targetX ) or ( casterY != targetY ) ) then
                set casterZ = GetUnitZ( casterSelf, casterX, casterY ) + GetUnitOutpactZ(caster)
                set d = Data.create()
                set distance = SquareRoot( distanceX * distanceX + distanceY * distanceY )
                set durationTimer = CreateTimerWJ()
                set angleXYZ = GetUnitTypeMissileArc(casterType)
                set length = GetUnitTypeMissileSpeed(casterType) * UPDATE_TIME
                set lengthZ = Sin( angleXYZ ) * length
                set moveTimer = CreateTimerWJ()
                set duration = distance / length * UPDATE_TIME / Cos( angleXYZ )
                set lengthZAdd = ( GetFloorHeight( targetX, targetY ) - casterZ - Tan( angleXYZ ) * distance ) * 2 * length * length * Cos( angleXYZ ) * Cos( angleXYZ ) / distance / distance
                set wavesAmount = R2I(duration / UPDATE_TIME)
                set lengthX = distanceX / wavesAmount
                set lengthY = distanceY / wavesAmount
                set d.caster = caster
                set d.dummyUnit = dummyUnit
                set d.lengthX = lengthX
                set d.lengthY = lengthY
                set d.lengthZ = lengthZ
                set d.lengthZAdd = lengthZAdd
                set d.moveTimer = moveTimer
                set d.targetX = targetX
                set d.targetY = targetY
                set d.x = casterX
                set d.y = casterY
                set d.z = casterZ
                call AttachInteger( durationTimer, ArtilleryAttack_SCOPE_ID, d )
                call AttachInteger( moveTimer, ArtilleryAttack_SCOPE_ID, d )
                call AddUnitRemainingReference( caster )
                call SetUnitZ( dummyUnit, casterX, casterY, casterZ )
                call SetUnitAnimation( dummyUnit, "stand" )
                set dummyUnit = null
                call TimerStart( moveTimer, UPDATE_TIME, true, function Move )
                set moveTimer = null
                call TimerStart( durationTimer, duration, false, function Ending )
                set durationTimer = null
            else
                call Impact( caster, dummyUnit, targetX, targetY )
            endif
        endif
        set casterSelf = null
    endfunction

    public function Init takes nothing returns nothing
        call InitAbility( SPELL_ID )
    endfunction
//! runtextmacro Endscope()