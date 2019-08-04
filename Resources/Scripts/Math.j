//! runtextmacro Folder("Math")
    //! runtextmacro Struct("Integer")
        static integer MIN = -2147483645
    endstruct
endscope

function Atan_Wrapped takes real x returns real
    return Atan(x)
endfunction

function Cosinus takes real x returns real
    return Cos(x)
endfunction

function Sinus takes real x returns real
    return Sin(x)
endfunction

//! runtextmacro StaticStruct("Math")
    static constant real EPSILON = 0.01
    static integer array LOGS_OF_2I
    static constant integer LOGS_OF_2I_COUNT = 1024
    static constant real PI = 3.141592654

    static constant real DEG_TO_RAD = PI / 180.
    static constant real DOUBLE_PI = 2 * PI
    static constant real EAST_ANGLE = 0.
    static constant real FULL_ANGLE = DOUBLE_PI
    static constant real HALF_ANGLE = PI
    static constant real HALF_PI = PI / 2
    static constant real NORTH_ANGLE = 0.5 * PI
    static integer array POWERS_OF_2I
    static constant integer POWERS_OF_2I_COUNT = 20
    static constant real QUARTER_ANGLE = HALF_PI
    static constant real RAD_TO_DEG = 180. / PI
    static constant real SOUTH_ANGLE = 1.5 * PI
    static constant real WEST_ANGLE = PI

    //! runtextmacro LinkToStaticStruct("Math", "Integer")

    static method Atan takes real x returns real
        return Atan_Wrapped(x)
    endmethod

    static method AtanByDeltas takes real y, real x returns real
        return Atan2(y, x)
    endmethod

    static method Cos takes real x returns real
        return Cosinus(x)
    endmethod

    static method Sin takes real x returns real
        return Sinus(x)
    endmethod

    static method Sqrt takes real a returns real
        return SquareRoot(a)
    endmethod

    static method DistanceByDeltas takes real x, real y returns real
        return thistype.Sqrt(x * x + y * y)
    endmethod

    static method DistanceSquareByDeltas takes real x, real y returns real
        return (x * x + y * y)
    endmethod

    static method DistanceByDeltasWithZ takes real x, real y, real z returns real
        return thistype.Sqrt(x * x + y * y + z * z)
    endmethod

    static method Max takes real a, real b returns real
        if ( a > b ) then
            return a
        endif

        return b
    endmethod

    static method MaxI takes integer a, integer b returns integer
        return Real.ToInt( thistype.Max( a, b ) )
    endmethod

    static method Min takes real a, real b returns real
        if ( a < b ) then
            return a
        endif

        return b
    endmethod

    static method Limit takes real value, real b, real c returns real
        return thistype.Min(thistype.Max(b, value), c)
    endmethod

    static method MinI takes integer a, integer b returns integer
        return Real.ToInt( thistype.Min( a, b ) )
    endmethod

    static method MinMax takes real a, real b, boolean flag returns real
        if ( flag ) then
            return thistype.Max( a, b )
        endif

        return thistype.Min( a, b )
    endmethod

    static method MinMaxI takes integer a, integer b, boolean flag returns integer
        return Real.ToInt( thistype.MinMax( a, b, flag ) )
    endmethod

    static method Abs takes real a returns real
        if ( a < 0 ) then
            return -a
        endif

        return a
    endmethod

    static method Compare takes real a, limitop whichOperator, real b returns boolean
        if (whichOperator == LESS_THAN) then
            if (a < b) then
                return true
            endif
        elseif (whichOperator == LESS_THAN_OR_EQUAL) then
            if (a <= b) then
                return true
            endif
        elseif (whichOperator == EQUAL) then
            if (a == b) then
                return true
            endif
        elseif (whichOperator == NOT_EQUAL) then
            if (a != b) then
                return true
            endif
        elseif (whichOperator == GREATER_THAN) then
            if (a > b) then
                return true
            endif
        elseif (whichOperator == GREATER_THAN_OR_EQUAL) then
            if (a >= b) then
                return true
            endif
        endif

        return false
    endmethod

    static method CompareMinMax takes real a, real b, boolean flag returns boolean
        if ( flag ) then
            if ( a > b ) then
                return true
            endif
        else
            if ( a < b ) then
                return true
            endif
        endif

        return false
    endmethod

    static method RandomI takes integer lowBound, integer highBound returns integer
        return GetRandomInt(lowBound, highBound)
    endmethod

    static method Random takes real lowBound, real highBound returns real
        return GetRandomReal(lowBound, highBound)
    endmethod

    static method RandomLowRange takes real lowBound, real range returns real
        return thistype.Random(lowBound, lowBound + range)
    endmethod

    static method RandomAngle takes nothing returns real
        return thistype.Random(0., FULL_ANGLE)
    endmethod

    static method Sign takes real a returns integer
        if ( a < 0 ) then
            return -1
        elseif ( a == 0 ) then
            return 0
        endif

        return 1
    endmethod

    static method Power takes real base, real exponent returns real
        return Pow( base, exponent )
    endmethod

    static method PowerI takes integer base, integer exponent returns integer
        return Real.ToInt( thistype.Power( base, exponent ) )
    endmethod

    static method PowerOf2I takes integer exponent returns integer
        if (exponent > thistype.POWERS_OF_2I_COUNT) then
            call BJDebugMsg("PowerOf2I: " + "index was too HIGH ("+I2S(exponent)+")")

            return thistype.PowerI(exponent, 2)
        endif

        return thistype.POWERS_OF_2I[exponent]
    endmethod

    static method AngleBetweenVectors takes real aX, real aY, real bX, real bY returns real
        return Acos( ( aX * bX + aY * bY ) / ( SquareRoot( aX * aX + aY * aY ) * SquareRoot( bX * bX + bY * bY ) ) )
    endmethod

    static method AreCoordinatesInTriangle_Child takes real aX, real aY, real bX, real bY, real cX, real cY returns integer
        return thistype.Sign( aX * ( bY - cY ) + aY * ( cX - bX ) + bX * cY - bY * cX )
    endmethod

    static method AreCoordinatesInTriangle takes real aX, real aY, real bX, real bY, real cX, real cY, real x, real y returns boolean
        local real averageX = ( aX + bX + cX ) / 3
        local real averageY = ( aY + bY + cY ) / 3

        if ( AreCoordinatesInTriangle_Child( averageX, averageY, aX, aY, bX, bY ) == AreCoordinatesInTriangle_Child( x, y, aX, aY, bX, bY ) ) then
            if ( AreCoordinatesInTriangle_Child( averageX, averageY, aX, aY, cX, cY ) == AreCoordinatesInTriangle_Child( x, y, aX, aY, cX, cY ) ) then
                if ( AreCoordinatesInTriangle_Child( averageX, averageY, bX, bY, cX, cY ) == AreCoordinatesInTriangle_Child( x, y, bX, bY, cX, cY ) ) then
                    return true
                endif
            endif
        endif

        return false
    endmethod

    static method AreCoordinatesInQuadrilateral takes real aX, real aY, real bX, real bY, real cX, real cY, real dX, real dY, real x, real y returns boolean
        if ( ( AngleBetweenVectors( bX - aX, bY - aY, dX - aX, dY - aY ) + AngleBetweenVectors( bX - cX, bY - cY, dX - cX, dY - cY ) ) > ( AngleBetweenVectors( aX - bX, aY - bY, cX - bX, cY - bY ) + AngleBetweenVectors( aX - dX, aY - dY, cX - dX, cY - dY ) ) ) then
            if ( ( AreCoordinatesInTriangle(aX, aY, bX, bY, cX, cY, x, y ) ) or ( AreCoordinatesInTriangle( aX, aY, cX, cY, dX, dY, x, y ) ) ) then
                return true
            endif
        else
            if ( ( AreCoordinatesInTriangle( aX, aY, bX, bY, dX, dY, x, y ) ) or ( AreCoordinatesInTriangle( bX, bY, cX, cY, dX, dY, x, y ) ) ) then
                return true
            endif
        endif

        return false
    endmethod

    static method Mod takes real dividend, real divisor returns real
        local real result

        //set dividend = thistype.CutReal( dividend )
        //set divisor = thistype.CutReal( divisor )

        if ( divisor == 0 ) then
            set result = -1
        else
            set result = dividend - Real.ToInt( dividend / divisor ) * divisor
            if ( result < 0 ) then
                set result = result + divisor
            endif
        endif
        return result
    endmethod

    static method ModI takes integer dividend, integer divisor returns integer
        return Real.ToInt( thistype.Mod( dividend, divisor ) )
    endmethod

    static method RoundTo_GetDifference takes real dividend, real divisor returns real
        return thistype.Abs( dividend - Real.ToInt( dividend / divisor ) * divisor )
    endmethod

    static method RoundTo takes real base, real interval returns real
        local real difference
        local real difference2

        if ( interval == 0 ) then
            return 0.
        endif

        set difference = RoundTo_GetDifference( base, interval )

        set difference2 = Abs( interval ) - difference

        if ( difference2 < difference ) then
            return ( base + Sign( interval ) * difference2 )
        endif

        return ( base - Sign( interval ) * difference )
    endmethod

    static method AngleBetweenCoords takes real x1, real y1, real x2, real y2 returns real
        return Atan2( y2 - y1, x2 - x1 )
    endmethod

    static method AngleDifference takes real a, real b returns real
        local real result

        set a = thistype.Mod( a, FULL_ANGLE )
        set b = thistype.Mod( b, FULL_ANGLE )

        set result = thistype.Abs( a - b )

        if ( result > PI ) then
            return ( DOUBLE_PI - result )
        endif

        return result
    endmethod

    static method CompareAngles takes real a, real b returns boolean
        set a = thistype.Mod( a, FULL_ANGLE )
        set b = thistype.Mod( b, FULL_ANGLE )

        if ( a < b ) then
            return false
        endif

        return true
    endmethod

    static method LimitAngle takes real value, real lowBound, real highBound returns real
        local real valueHighBoundD
        local real valueLowBoundD

        //set highBound = thistype.Mod(lowBound, FULL_ANGLE)
        //set lowBound = thistype.Mod(lowBound, FULL_ANGLE)
        //set value = thistype.Mod(value, FULL_ANGLE)

        set valueHighBoundD = thistype.AngleDifference(value, highBound)
        set valueLowBoundD = thistype.AngleDifference(value, lowBound)

        if (valueLowBoundD + valueHighBoundD - EPSILON > thistype.Abs(highBound - lowBound)) then
            if (valueLowBoundD < valueHighBoundD) then
                return lowBound
            endif

            return highBound
        endif

        return value
    endmethod

    static method Log takes real a, real b returns integer
        local integer result

        if ( a == 0 ) then
            return 0
        endif

        set result = 0

        loop
            exitwhen ( Pow( b, result / 10. ) >= a )

            set result = result + 10
        endloop

        loop
            exitwhen ( Pow( b, result / 10. ) <= a )

            set result = result - 1
        endloop

        return ( result / 10 )
    endmethod

    static method LogI takes integer a, integer b returns integer
        return thistype.Log(a, b)
    endmethod

    static method LogOf2I takes integer a returns integer
        if (a > thistype.LOGS_OF_2I_COUNT) then
            //call BJDebugMsg("LogOf2I: " + "index was too HIGH ("+I2S(a)+")")

            return thistype.LogI(a, 2)
        endif

        return thistype.LOGS_OF_2I[a]
    endmethod

    static method LogOf2I_Init takes nothing returns nothing
        local integer iteration = TEMP_INTEGER

        loop
            exitwhen (iteration < ARRAY_MIN)

            set thistype.LOGS_OF_2I[iteration] = thistype.LogI(iteration, 2)
            set iteration = iteration - 1

            set TEMP_INTEGER2 = TEMP_INTEGER2 + 1
            exitwhen (TEMP_INTEGER2 > 500)
        endloop

        if (iteration > ARRAY_EMPTY) then
            set TEMP_INTEGER = iteration
            set TEMP_INTEGER2 = 0

            call Code.Run(function thistype.LogOf2I_Init)
        endif
    endmethod

    static method Init takes nothing returns nothing
        local integer iteration = thistype.POWERS_OF_2I_COUNT

        loop
            exitwhen (iteration < ARRAY_MIN)

            set thistype.POWERS_OF_2I[iteration] = thistype.PowerI(2, iteration)

            set iteration = iteration - 1
        endloop

        set TEMP_INTEGER = thistype.LOGS_OF_2I_COUNT
        set TEMP_INTEGER2 = 0

        call Code.Run(function thistype.LogOf2I_Init)
    endmethod
endstruct

/*function Absolute takes real a returns real
    return Math.Abs(a)
endfunction

function Log takes real a, real b returns integer
    return Math.Log(a, b)
endfunction

function Max takes real a, real b returns real
    return Math.Max(a, b)
endfunction

function MaxI takes integer a, integer b returns integer
    return Math.MaxI(a, b)
endfunction

function Min takes real a, real b returns real
    return Math.Min(a, b)
endfunction

function MinI takes integer a, integer b returns integer
    return Math.MinI(a, b)
endfunction

function Sign takes real a returns integer
    return Math.Sign(a)
endfunction*/