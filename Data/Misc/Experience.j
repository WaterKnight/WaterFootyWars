//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Experience")
    globals
        private constant real AREA_RANGE = 1500.
        public boolean array DISABLED
        private constant real EP_HERO_LEVEL_FACTOR = 65.
        private group ENUM_GROUP
        private real array LEVEL_FACTOR
        private boolexpr TARGET_CONDITIONS
    endglobals

    private function TargetConditions takes nothing returns boolean
        local real distance
        set FILTER_UNIT_SELF = GetFilterUnit()
        if ( GetUnitState( FILTER_UNIT_SELF, UNIT_STATE_LIFE ) <= 0 ) then
            return false
        endif
        if ( IsUnitAlly( FILTER_UNIT_SELF, TEMP_PLAYER ) == false ) then
            return false
        endif
        if ( IsUnitType( FILTER_UNIT_SELF, UNIT_TYPE_HERO ) == false ) then
            return false
        endif
        if ( IsUnitIllusionWJ( GetUnit(FILTER_UNIT_SELF) ) ) then
            return false
        endif
        set distance = DistanceByCoordinates( TEMP_REAL, TEMP_REAL2, GetUnitX(FILTER_UNIT_SELF), GetUnitY(FILTER_UNIT_SELF) )
        set TEMP_INTEGER = TEMP_INTEGER + 1
        if ( distance == 0 ) then
            set TEMP_INTEGER2 = TEMP_INTEGER2 + 1
        else
            set TEMP_REAL3 = TEMP_REAL3 + distance
        endif
        return true
    endfunction

    private function Death_Conditions takes boolean deathCausedByEnemy, player killingUnitOwner, integer killingUnitTeam returns boolean
        if ( DISABLED[killingUnitTeam] ) then
            return false
        endif
        if ( deathCausedByEnemy == false ) then
            return false
        endif
        return true
    endfunction

    public function Death takes boolean deathCausedByEnemy, Unit dyingUnit, UnitType dyingUnitType, real dyingUnitX, real dyingUnitY, player killingUnitOwner, integer killingUnitTeam returns nothing
        local unit enumUnit
        local real ep
        local integer previousLevel
        if ( Death_Conditions( deathCausedByEnemy, killingUnitOwner, killingUnitTeam ) ) then
            set TEMP_INTEGER = 0
            set TEMP_INTEGER2 = 0
            set TEMP_PLAYER = killingUnitOwner
            set TEMP_REAL = dyingUnitX
            set TEMP_REAL2 = dyingUnitY
            set TEMP_REAL3 = 0
            call GroupEnumUnitsInRangeWJ( ENUM_GROUP, dyingUnitX, dyingUnitY, AREA_RANGE, TARGET_CONDITIONS )
            set enumUnit = FirstOfGroup( ENUM_GROUP )
            if ( enumUnit != null ) then
                set ep = GetUnitTypeEP(dyingUnitType) + GetHeroLevel( dyingUnit.self ) * EP_HERO_LEVEL_FACTOR
                set previousLevel = GetHeroLevel( enumUnit )
                if ( TEMP_INTEGER2 > 0 ) then
                    loop
                        call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                        set previousLevel = GetHeroLevel( enumUnit )
                        call AddUnitEP( enumUnit, LEVEL_FACTOR[previousLevel] * ep / TEMP_INTEGER2 )
                        set enumUnit = FirstOfGroup( ENUM_GROUP )
                        exitwhen ( enumUnit == null )
                    endloop
                elseif ( TEMP_INTEGER > 1 ) then
                    loop
                        call GroupRemoveUnit( ENUM_GROUP, enumUnit )
                        call AddUnitEP( enumUnit, LEVEL_FACTOR[previousLevel] * ep * ( 1 - DistanceByCoordinates( dyingUnitX, dyingUnitY, GetUnitX(enumUnit), GetUnitY(enumUnit) ) / TEMP_REAL3 ) )
                        set enumUnit = FirstOfGroup( ENUM_GROUP )
                        exitwhen ( enumUnit == null )
                    endloop
                else
                    call AddUnitEP( enumUnit, LEVEL_FACTOR[previousLevel] * ep )
                endif
            endif
        endif
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = GetTeams()
        loop
            set DISABLED[iteration] = false
            set iteration = iteration - 1
            exitwhen (iteration < 0)
        endloop
        set ENUM_GROUP = CreateGroupWJ()
        set LEVEL_FACTOR[1] = 1.5
        set LEVEL_FACTOR[2] = 1.45
        set LEVEL_FACTOR[3] = 1.4
        set LEVEL_FACTOR[4] = 1.36
        set LEVEL_FACTOR[5] = 1.32
        set LEVEL_FACTOR[6] = 1.29
        set LEVEL_FACTOR[7] = 1.26
        set LEVEL_FACTOR[8] = 1.23
        set LEVEL_FACTOR[9] = 1.2
        set LEVEL_FACTOR[10] = 1.18
        set LEVEL_FACTOR[11] = 1.16
        set LEVEL_FACTOR[12] = 1.14
        set LEVEL_FACTOR[13] = 1.12
        set LEVEL_FACTOR[14] = 1.1
        set LEVEL_FACTOR[15] = 1.09
        set LEVEL_FACTOR[16] = 1.08
        set TARGET_CONDITIONS = ConditionWJ(function TargetConditions)
    endfunction
//! runtextmacro Endscope()