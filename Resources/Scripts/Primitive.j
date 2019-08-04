//! runtextmacro StaticStruct("Boolean")
    static method ToInt takes boolean self returns integer
        if (self) then
            return 1
        endif

        return 0
    endmethod

    static method ToIntEx takes boolean self returns integer
        if (self) then
            return 1
        endif

        return -1
    endmethod

    static method Init takes nothing returns nothing
    endmethod
endstruct

//! runtextmacro StaticStruct("Char")
    static constant string BREAK = "\n"
    static constant string EXCLAMATION_MARK = "!"
    static constant string PERCENT = "%"
    static constant string QUOTE = "\""

    static method Init takes nothing returns nothing
    endmethod
endstruct

//! runtextmacro StaticStruct("Code")
    static hashtable CACHE = InitHashtable()
    static trigger DUMMY_TRIGGER = CreateTrigger()
    static triggeraction DUMMY_TRIGGER_ACTION = null
    static trigger LIST_DUMMY_TRIGGER = CreateTrigger()

    static method GetId takes code self returns integer
        return GetHandleId(Condition(self))
    endmethod

    static method ClearRunList takes nothing returns nothing
        call TriggerClearActions(thistype.LIST_DUMMY_TRIGGER)
    endmethod

    static method AddToRunList takes code self returns nothing
        call TriggerAddAction(thistype.LIST_DUMMY_TRIGGER, self)
    endmethod

    static method RunList takes nothing returns nothing
        //call thistype.AddToRunList(function thistype.ClearRunList)

        call TriggerExecute(thistype.LIST_DUMMY_TRIGGER)
    endmethod

    static method Run takes code self returns nothing
        if (thistype.DUMMY_TRIGGER_ACTION != null) then
            call TriggerRemoveAction(thistype.DUMMY_TRIGGER, thistype.DUMMY_TRIGGER_ACTION)
        endif

        set thistype.DUMMY_TRIGGER_ACTION = TriggerAddAction(thistype.DUMMY_TRIGGER, self)
//call BJDebugMsg("test")
        call TriggerExecuteWait(thistype.DUMMY_TRIGGER)
    endmethod

    static method Init takes nothing returns nothing
    endmethod
endstruct

//! runtextmacro StaticStruct("Integer")
    static method ToBoolean takes integer self returns boolean
        if (self > 0) then
            return true
        endif

        return false
    endmethod

    static method ToString takes integer self returns string
        return I2S(self)
    endmethod

    static method Init takes nothing returns nothing
    endmethod
endstruct

//! runtextmacro Folder("Real")
    //! runtextmacro Struct("Event")
        //! textmacro Real_Event_CreateResponse takes var, func
            static real $var$

            static method Get$func$ takes nothing returns real
                return thistype.$var$
            endmethod

            static method Set$func$ takes real self returns nothing
                set thistype.$var$ = self
            endmethod
        //! endtextmacro

        //! runtextmacro Real_Event_CreateResponse("TRIGGER", "Trigger")
    endstruct
endscope

//! runtextmacro StaticStruct("Real")
    //! runtextmacro LinkToStaticStruct("Real", "Event")

    static method Case takes string whichString, boolean flag returns string
        return StringCase(whichString, flag)
    endmethod

    static method ToInt takes real self returns integer
        return R2I(self)
    endmethod

    static method ToIntString takes real self returns string
        return Integer.ToString(thistype.ToInt(self))
    endmethod

    static method ToPercentString takes real self returns string
        return (Integer.ToString(thistype.ToInt(self)) + Char.PERCENT)
    endmethod

    static method ToString takes real self returns string
        return R2S(self)
    endmethod

    static method ToStringWithDecimals takes real self, integer decimals returns string
        local integer iteration
        local string result
        local integer selfI

        if (self == 0.) then
            return ("0." + String.Repeat("0", decimals))
        endif

        set iteration = decimals
        set selfI = Real.ToInt(self)

        loop
            exitwhen (iteration < 1)

            set self = self * 10

            set iteration = iteration - 1
        endloop

        set result = Integer.ToString(Real.ToInt(self))

        set result = (Integer.ToString(selfI) + "." + String.SubRightByWidth(result, decimals))

        return result
    endmethod

    static method Init takes nothing returns nothing
    endmethod
endstruct

//! runtextmacro Folder("String")
    //! runtextmacro Struct("Color")
        static string array HEX_MAP
        static constant string RESET = "|r"
        static constant string START = "|cff"

        static constant string BLACK = thistype.START + "000000"
        static constant string BONUS = thistype.START + "00ff00"
        static constant string GOLD = thistype.START + "ffcc00"
        static constant string GREEN = thistype.START + "00ff00"
        static constant string MALUS = thistype.START + "ff0000"
        static constant string RED = thistype.START + "ff0000"

        static method DecToHex takes integer dec returns string
            local string result = ""
            local integer value

            loop
                exitwhen (dec < 16)

                set value = Math.MinI(dec / 16, 15)

                set dec = dec - value * 16
                set result = result + thistype.HEX_MAP[value]
            endloop

            return (result + thistype.HEX_MAP[dec])
        endmethod

        static method HexToColorHex takes string value returns string
            return (String.If(String.Length(value) == String.MIN_LENGTH, thistype.HEX_MAP[0]) + value)
        endmethod

        static method RelativeTo takes real red, real green, real blue returns string
            local string result = thistype.START

            set result = result + thistype.HexToColorHex(thistype.DecToHex(Real.ToInt(red * 255.)))

            set result = result + thistype.HexToColorHex(thistype.DecToHex(Real.ToInt(green * 255.)))

            set result = result + thistype.HexToColorHex(thistype.DecToHex(Real.ToInt(blue * 255.)))

            return result
        endmethod

        static method Init takes nothing returns nothing
            set thistype.HEX_MAP[0] = "0"
            set thistype.HEX_MAP[1] = "1"
            set thistype.HEX_MAP[2] = "2"
            set thistype.HEX_MAP[3] = "3"
            set thistype.HEX_MAP[4] = "4"
            set thistype.HEX_MAP[5] = "5"
            set thistype.HEX_MAP[6] = "6"
            set thistype.HEX_MAP[7] = "7"
            set thistype.HEX_MAP[8] = "8"
            set thistype.HEX_MAP[9] = "9"
            set thistype.HEX_MAP[10] = "A"
            set thistype.HEX_MAP[11] = "B"
            set thistype.HEX_MAP[12] = "C"
            set thistype.HEX_MAP[13] = "D"
            set thistype.HEX_MAP[14] = "E"
            set thistype.HEX_MAP[15] = "F"
        endmethod
    endstruct
endscope

//! runtextmacro StaticStruct("String")
    static constant integer MIN_LENGTH = 1

    //! runtextmacro LinkToStaticStruct("String", "Color")

    static method Case takes string self, boolean flag returns string
        return StringCase(self, flag)
    endmethod

    static method If takes boolean flag, string self returns string
        if (flag) then
            return self
        endif

        return ""
    endmethod

    static method IfElse takes boolean flag, string self, string self2 returns string
        if (flag) then
            return self
        endif

        return self2
    endmethod

    static method Length takes string self returns integer
        return StringLength(self)
    endmethod

    static method Sub takes string self, integer start, integer end returns string
        return SubString(self, start, end + thistype.MIN_LENGTH)
    endmethod

    static method Find takes string self, string value, integer index returns integer
        local integer iteration = -1
        local integer length = thistype.Length(self)
        local integer valueLength = thistype.Length(value)

        loop
            exitwhen (index < 0)

            set iteration = iteration + 1

            loop
                exitwhen (thistype.Sub(self, iteration, iteration + valueLength - thistype.MIN_LENGTH) == value)

                if (iteration == length) then
                    return -1
                endif

                set iteration = iteration + 1
            endloop

            set index = index - 1
        endloop

        return iteration
    endmethod

    static method Repeat takes string self, integer amount returns string
        local string result = ""

        loop
            exitwhen (amount < 1)

            set result = result + self

            set amount = amount - 1
        endloop

        return result
    endmethod

    static method Unfind takes string self, string value, integer index returns integer
        local integer iteration = -1
        local integer length = thistype.Length(self)
        local integer valueLength = thistype.Length(value)

        loop
            exitwhen (index < 0)

            set iteration = iteration + 1

            loop
                exitwhen (thistype.Sub(self, iteration, iteration + valueLength - thistype.MIN_LENGTH) != value)

                if (iteration == length) then
                    return -1
                endif

                set iteration = iteration + 1
            endloop

            set index = index - 1
        endloop

        return iteration
    endmethod

    static method SubLeft takes string self, integer end returns string
        return thistype.Sub(self, 0, end)
    endmethod

    static method SubRight takes string self, integer start returns string
        return thistype.Sub(self, start, thistype.Length(self) - thistype.MIN_LENGTH)
    endmethod

    static method SubRightByWidth takes string self, integer width returns string
        local integer length = thistype.Length(self) - thistype.MIN_LENGTH

        return thistype.Sub(self, length - width + 1, length)
    endmethod

    static method ToReal takes string self returns real
        return S2R(self)
    endmethod

    static method Word takes string self, integer index returns string
        local integer pos

        set pos = thistype.Unfind(self, " ", 0)

        set self = thistype.SubRight(self, pos)

        set pos = thistype.Find(self, " ", 0)

        if (index == 0) then
            return thistype.SubLeft(self, pos - 1)
        endif

        set index = index - 1

        loop
            set self = thistype.SubRight(self, pos)

            set pos = thistype.Unfind(self, " ", 0)

            set self = thistype.SubRight(self, pos)

            set pos = thistype.Find(self, " ", 0)

            if (index == 0) then
                return thistype.SubLeft(self, pos - 1)
            endif

            set index = index - 1
            exitwhen (index < 0)
        endloop
    endmethod

    static method Init takes nothing returns nothing
        call thistype.Color.Init()
    endmethod
endstruct

//! runtextmacro StaticStruct("Primitive")
    static method Init takes nothing returns nothing
        call Boolean.Init()
        call Char.Init()
        call Code.Init()
        call Integer.Init()
        call Real.Init()
        call String.Init()
    endmethod
endstruct