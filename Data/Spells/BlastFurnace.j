//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("BlastFurnace")
    globals
        private constant integer ORDER_ID = 852066//OrderId( "innerfire" )
        public constant integer SPELL_ID = 'A033'
    endglobals

    //! runtextmacro Scope("Extension")
        private function Ending takes integer IntervalTimer returns nothing
            call FlushAttachedReal( IntervalTimer, "MissileX" )
            call FlushAttachedReal( IntervalTimer, "MissileY" )
            call FlushAttachedReal( IntervalTimer, "MissileZ" )
        endfunction

        public function Extension_Abort takes integer IntervalTimer returns nothing
            local integer Caster = GetAttachedInteger( IntervalTimer, "Caster" )
            local integer Target = GetAttachedInteger( IntervalTimer, "Target" )
            call FlushAttachedInteger( Caster, "BlastFurnace_DrawTarget_IntervalTimer" )
            call FlushAttachedInteger( IntervalTimer, "AbilityLevel" )
            call FlushAttachedInteger( IntervalTimer, "Caster" )
            call FlushAttachedInteger( IntervalTimer, "Target" )
            call BlastFurnace_Extension_Ending( IntervalTimer )
            call DestroyTimerWJ( IntervalTimer )
            call RemoveIntegerFromTable( Target, "BlastFurnace_DrawTarget_Casters", Caster )
        endfunction

        public function Extension takes nothing returns nothing
            local real AngleRadianXY
            local real AngleRadianMoveLengthXYZ
            local real DistanceX
            local real DistanceY
            local real DistanceZ
            local real ChainLengthPartX
            local real ChainLengthPartY
            local real ChainLengthPartZ
            local integer ChainPart
            local integer IntervalTimer = GetExpiredTimerWJ()
            local integer AbilityLevel = GetAttachedInteger( IntervalTimer, "AbilityLevel" )
            local integer Caster = GetAttachedInteger( IntervalTimer, "Caster" )
            local real CasterX = GetUnitXWJ( Caster )
            local real CasterY = GetUnitXWJ( Caster )
            local real CasterZ = GetUnitXWJ( Caster ) + GetAttachedReal( Caster, "ImpactZ" )
            local integer ChainPartsAmount = GetAttachedInteger( BlastFurnace_Id(), "ChainPartsAmount" + I2S( AbilityLevel ) )
            local integer Iteration = 1
            local integer LoadAbility
            local real MissileX = GetAttachedReal( IntervalTimer, "MissileX" )
            local real MissileY = GetAttachedReal( IntervalTimer, "MissileY" )
            local real MissileZ = GetAttachedReal( IntervalTimer, "MissileZ" )
            local real MoveLengthXY
            local integer Target = GetAttachedInteger( IntervalTimer, "Target" )
            local real TargetX = GetUnitXWJ( Target )
            local real TargetY = GetUnitYWJ( Target )
            local real TargetZ = GetUnitZ( Target ) + GetAttachedReal( Target, "ImpactZ" )
            local real MoveLength = GetAttachedReal( BlastFurnace_Id(), "MoveLength" + I2S( AbilityLevel ) )
            local boolean ReachesTarget = ( DistanceByCoordinatesWithZ( TargetX, TargetY, TargetZ, CasterX, CasterY, CasterZ ) <= MoveLength )
            if ( ReachesTarget ) then
                set MissileX = TargetX
                set MissileY = TargetY
                set MissileZ = TargetZ
            else
                set DistanceX = TargetX - MissileX
                set DistanceY = TargetY - MissileY
                set DistanceZ = TargetZ - MissileZ
                set AngleRadianMoveLengthXYZ = Atan2( DistanceZ, DistanceByCoordinates( MissileX, MissileY, TargetX, TargetY ) )
                set AngleRadianXY = Atan2( DistanceY, DistanceX )
                set MoveLengthXY = MoveLength * Cos( AngleRadianMoveLengthXYZ )
                set MissileX = MissileX + MoveLengthXY * Cos( AngleRadianXY )
                set MissileY = MissileY + MoveLengthXY * Sin( AngleRadianXY )
                set MissileZ = MissileZ + MoveLength * Sin( AngleRadianMoveLengthXYZ )
                call AttachReal( IntervalTimer, "MissileX", MissileX )
                call AttachReal( IntervalTimer, "MissileY", MissileY )
                call AttachReal( IntervalTimer, "MissileZ", MissileZ )
            endif
            set ChainLengthPartX = ( MissileX - CasterX ) / ChainPartsAmount
            set ChainLengthPartY = ( MissileY - CasterY ) / ChainPartsAmount
            set ChainLengthPartZ = ( MissileZ - CasterZ ) / ChainPartsAmount
            loop
                exitwhen ( Iteration > ChainPartsAmount )
                set ChainPart = GetIntegerFromTable( IntervalTimer, "ChainParts", Iteration )
                call SetUnitXWJ( ChainPart, CasterX + Iteration * ChainLengthPartX )
                call SetUnitXWJ( ChainPart, CasterY + Iteration * ChainLengthPartY )
                call SetUnitXWJ( ChainPart, CasterZ + Iteration * ChainLengthPartZ )
                set Iteration = Iteration + 1
            endloop
            if ( ReachesTarget ) then
                call BlastFurnace_Extension_Ending( IntervalTimer )
        //        call TimerStartWJ( IntervalTimer, GetAttachedReal( BlastFurnace_Id(), "Interval" ), true, function BlastFurnace_DrawTarget_MoveTarget )
            endif
        endfunction
    //! runtextmacro Endscope()

    public function SpellEffect takes integer Caster, integer Target returns nothing
        local integer AbilityLevel = GetUnitAbilityLevelWJ( Caster, BlastFurnace_Id() )
        local real CasterTargetAngle
        local real CasterX = GetUnitXWJ( Caster )
        local real CasterY = GetUnitYWJ( Caster )
        local real CasterZ = GetUnitXWJ( Caster ) + GetAttachedReal( Caster, "ImpactZ" )
        local integer ChainPartUnitTypeId = GetAttachedInteger( BlastFurnace_Id(), "ChainPartUnitTypeId" )
        local integer IntervalTimer = CreateTimerWJ()
        local integer newChainPart
        local real TargetX = GetUnitXWJ( Target )
        local real TargetY = GetUnitYWJ( Target )
        if ( ( CasterX != TargetX ) or ( CasterX != TargetX ) ) then
            set CasterTargetAngle = Atan2( TargetY - CasterY, TargetX - CasterX )
        else
            set CasterTargetAngle = GetUnitFacingWJ( Caster )
        endif
        call AttachInteger( Caster, "BlastFurnace_DrawTarget_IntervalTimer", IntervalTimer )
        call AttachInteger( IntervalTimer, "AbilityLevel", AbilityLevel )
        call AttachInteger( IntervalTimer, "Caster", Caster )
        call AddIntegerToTable( Target, "BlastFurnace_DrawTarget_Casters", Caster )
        loop
            set newChainPart = CreateUnitWJ( PlayerWJ( PLAYER_NEUTRAL_PASSIVE ), ChainPartUnitTypeId, CasterX, CasterY, CasterTargetAngle )
            call SetUnitZWJ( newChainPart, CasterZ )
            call AddIntegerToTable( IntervalTimer, "ChainParts", newChainPart )
        endloop
        call TimerStartWJ( IntervalTimer, GetAttachedReal( BlastFurnace_Id(), "Interval" ), true, function Extension )
    endfunction
//! runtextmacro Endscope()