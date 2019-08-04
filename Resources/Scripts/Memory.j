//! runtextmacro Folder("GameCache")
    //! textmacro GameCache_CreateType takes getFunc, setFunc, type, defaultValue
        static constant $type$ DEFAULT_VALUE = $defaultValue$

        method Get takes string missionKey, string key returns $type$
            return $getFunc$(GameCache(this).self, missionKey, key)
        endmethod

        method Set takes string missionKey, string key, $type$ value returns nothing
            call $setFunc$(GameCache(this).self, missionKey, key, value)
        endmethod

        method Remove takes string missionKey, string key returns nothing
            call this.Set(missionKey, key, thistype.DEFAULT_VALUE)
        endmethod
    //! endtextmacro

    //! runtextmacro Struct("Boolean")
        //! runtextmacro GameCache_CreateType("GetStoredBoolean", "StoreBoolean", "boolean", "false")
    endstruct

    //! runtextmacro Struct("Integer")
        //! runtextmacro GameCache_CreateType("GetStoredInteger", "StoreInteger", "integer", "0")
    endstruct

    //! runtextmacro Struct("Real")
        //! runtextmacro GameCache_CreateType("GetStoredReal", "StoreReal", "real", "0.")
    endstruct

    //! runtextmacro Struct("String")
        //! runtextmacro GameCache_CreateType("GetStoredString", "StoreString", "string", "\"\"")
    endstruct
endscope

//! runtextmacro BaseStruct("GameCache", "GAME_CACHE")
    gamecache self

    //! runtextmacro LinkToStruct("GameCache", "Boolean")
    //! runtextmacro LinkToStruct("GameCache", "Integer")
    //! runtextmacro LinkToStruct("GameCache", "Real")
    //! runtextmacro LinkToStruct("GameCache", "String")

    method RemoveMission takes string missionKey returns nothing
        call FlushStoredMission(this.self, missionKey)
    endmethod

    static method Create takes nothing returns thistype
        local thistype this = thistype.allocate()

        set this.self = InitGameCache("bla")

        return this
    endmethod
endstruct

//! runtextmacro Folder("HashTable")
    //! textmacro HashTable_CreateType takes getFunc, setFunc, type, defaultValue, bugConv
        static constant $type$ DEFAULT_VALUE = $defaultValue$

        method Get takes integer missionKey, integer key returns $type$
            return $getFunc$(HashTable(this).self, missionKey, key)
        endmethod

        method Set takes integer missionKey, integer key, $type$ value returns nothing
            call $setFunc$(HashTable(this).self, missionKey, key, value)
        endmethod

        method Remove takes integer missionKey, integer key returns nothing
            call this.Set(missionKey, key, thistype.DEFAULT_VALUE)
        endmethod
    //! endtextmacro

    //! runtextmacro Struct("Boolean")
        //! runtextmacro HashTable_CreateType("LoadBoolean", "SaveBoolean", "boolean", "false", "B2S")
    endstruct

    //! runtextmacro Struct("Integer")
        //! runtextmacro HashTable_CreateType("LoadInteger", "SaveInteger", "integer", "0", "I2S")
    endstruct

    //! runtextmacro Struct("Real")
        //! runtextmacro HashTable_CreateType("LoadReal", "SaveReal", "real", "0.", "R2S")
    endstruct

    //! runtextmacro Struct("String")
        //! runtextmacro HashTable_CreateType("LoadStr", "SaveStr", "string", "\"\"", "")
    endstruct
endscope

//! runtextmacro BaseStruct("HashTable", "HASH_TABLE")
    hashtable self

    //! runtextmacro LinkToStruct("HashTable", "Boolean")
    //! runtextmacro LinkToStruct("HashTable", "Integer")
    //! runtextmacro LinkToStruct("HashTable", "Real")
    //! runtextmacro LinkToStruct("HashTable", "String")

    method RemoveMission takes integer missionKey returns nothing
        call FlushChildHashtable(this.self, missionKey)
    endmethod

    static method Create takes nothing returns thistype
        local thistype this = thistype.allocate()

        set this.self = InitHashtable()

        return this
    endmethod
endstruct

//! runtextmacro Folder("Memory")
    //! runtextmacro Folder("IntegerKeys")
        //! runtextmacro Struct("Table")
            static constant integer EMPTY = -1
            static constant integer OFFSET = 8192
            static constant integer SIZE = 8192
            static constant integer STARTED = 0

            static method Clear takes integer missionKey, integer key returns nothing
                call Memory.IntegerKeys.SetInteger(missionKey, key, 0)
            endmethod

            //! textmacro Memory_IntegerKeys_Table_CreateType takes name, type, bugConverter
                static method Count$name$s takes integer missionKey, integer key returns integer
                    return (thistype.EMPTY + Memory.IntegerKeys.GetInteger(missionKey, key))
                endmethod

                static method Count$name$sByHandle takes handle handleSource, integer key returns integer
                    return thistype.Count$name$s(GetHandleId(handleSource), key)
                endmethod

                static method Get$name$ takes integer missionKey, integer key, integer index returns $type$
                    return Memory.IntegerKeys.Get$name$(missionKey, key + thistype.EMPTY + index + 2)
                endmethod

                static method Get$name$ByHandle takes handle handleSource, integer key, integer index returns $type$
                    return thistype.Get$name$(GetHandleId(handleSource), key, index)
                endmethod

                static method Contains$name$ takes integer missionKey, integer key, $type$ value returns boolean
                    local integer iteration = Count$name$s(missionKey, key)

                    loop
                        exitwhen (iteration < thistype.STARTED)

                        exitwhen (thistype.Get$name$(missionKey, key, iteration) == value)

                        set iteration = iteration - 1
                    endloop

                    if (iteration < thistype.STARTED) then
                        return false
                    endif

                    return true
                endmethod

                static method Add$name$ takes integer missionKey, integer key, $type$ value returns boolean
                    local integer count = thistype.Count$name$s(missionKey, key) + 1

                    call Memory.IntegerKeys.SetInteger(missionKey, key, count - thistype.EMPTY)

                    call Memory.IntegerKeys.Set$name$(missionKey, key + thistype.EMPTY + count + 2, value)

                    return (count == thistype.STARTED)
                endmethod

                static method AddSorted$name$ takes integer missionKey, integer key, $type$ value returns boolean
                    local integer count = thistype.Count$name$s(missionKey, key) + 1

                    call Memory.IntegerKeys.SetInteger(missionKey, key, count - thistype.EMPTY)

                    call Memory.IntegerKeys.Set$name$(missionKey, key + thistype.EMPTY + count + 2, value)

                    return (count == thistype.STARTED)
                endmethod

                static method Add$name$ByHandle takes handle handleSource, integer key, $type$ value returns boolean
                    return thistype.Add$name$(GetHandleId(handleSource), key, value)
                endmethod

                static method Remove$name$ takes integer missionKey, integer key, $type$ value returns boolean
                    local integer count = thistype.Count$name$s(missionKey, key)

                    local integer iteration = count

                    loop
debug                        exitwhen (iteration < thistype.STARTED)

                        exitwhen (thistype.Get$name$(missionKey, key, iteration) == value)

                        set iteration = iteration - 1
                    endloop

debug                    if (iteration < thistype.STARTED) then
debug                        call BJDebugMsg("Failed to remove "+$bugConverter$(value)+" from table "+I2S(key)+" of missionKey "+I2S(missionKey)+" ("+I2S(count)+")")
debug                    else
                    call Memory.IntegerKeys.Set$name$(missionKey, key + thistype.EMPTY + iteration + 2, thistype.Get$name$(missionKey, key, count))

                    set count = count - 1

                    call Memory.IntegerKeys.SetInteger(missionKey, key, count - thistype.EMPTY)
debug                    endif

                    return (count == thistype.EMPTY)
                endmethod

                static method RemoveSorted$name$ takes integer missionKey, integer key, $type$ value returns boolean
                    local integer count = thistype.Count$name$s(missionKey, key)

                    local integer iteration = count

                    loop
debug                        exitwhen (iteration < thistype.STARTED)

                        exitwhen (thistype.Get$name$(missionKey, key, iteration) == value)

                        set iteration = iteration - 1
                    endloop

debug                    if (iteration < thistype.STARTED) then
debug                        call BJDebugMsg("Failed to remove (sorted) "+$bugConverter$(value)+" from table "+I2S(key)+" of missionKey "+I2S(missionKey)+" ("+I2S(count)+")")
debug                    else
                    loop
                        exitwhen (iteration == count)

                        call Memory.IntegerKeys.Set$name$(missionKey, key + thistype.EMPTY + iteration + 2, thistype.Get$name$(missionKey, key, iteration + 1))

                        set iteration = iteration + 1
                    endloop

                    set count = count - 1

                    call Memory.IntegerKeys.SetInteger(missionKey, key, count - thistype.EMPTY)
debug                    endif

                    return (count == thistype.EMPTY)
                endmethod

                static method Remove$name$ByHandle takes handle handleSource, integer key, $type$ value returns boolean
                    return thistype.Remove$name$(GetHandleId(handleSource), key, value)
                endmethod

                static method Random$name$ takes integer missionKey, integer key, integer lowerBound, integer higherBound returns $type$
                    return thistype.Get$name$(missionKey, key, Math.RandomI(lowerBound, higherBound))
                endmethod

                static method Random$name$ByHandle takes handle handleSource, integer key, integer lowerBound, integer higherBound returns $type$
                    return thistype.Random$name$(GetHandleId(handleSource), key, lowerBound, higherBound)
                endmethod

                static method Random$name$All takes integer missionKey, integer key returns $type$
                    return thistype.Random$name$(missionKey, key, thistype.STARTED, Count$name$s(missionKey, key))
                endmethod
            //! endtextmacro

            //! runtextmacro Memory_IntegerKeys_Table_CreateType("Boolean", "boolean", "B2S")
            //! runtextmacro Memory_IntegerKeys_Table_CreateType("Integer", "integer", "I2S")
            //! runtextmacro Memory_IntegerKeys_Table_CreateType("Real", "real", "R2S")
            //! runtextmacro Memory_IntegerKeys_Table_CreateType("String", "string", "")
        endstruct
    endscope

    //! runtextmacro Struct("IntegerKeys")
        static HashTable CACHE

        //! runtextmacro LinkToStaticStruct("IntegerKeys", "Table")

        static method RemoveChild takes integer missionKey returns nothing
            call CACHE.RemoveMission(missionKey)
        endmethod

        //! textmacro Memory_IntegerKeys_CreateType takes name, type
            static method Set$name$ takes integer missionKey, integer key, $type$ value returns nothing
                call CACHE.$name$.Set(missionKey, key, value)
            endmethod

            static method Set$name$ByHandle takes handle handleSource, integer key, $type$ value returns nothing
                call thistype.Set$name$(GetHandleId(handleSource), key, value)
            endmethod

            static method Remove$name$ takes integer missionKey, integer key returns nothing
                call CACHE.$name$.Remove(missionKey, key)
            endmethod

            static method Remove$name$ByHandle takes handle handleSource, integer key returns nothing
                call thistype.Remove$name$(GetHandleId(handleSource), key)
            endmethod

            ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

            static method Get$name$ takes integer handleSource, integer key returns $type$
                return CACHE.$name$.Get(handleSource, key)
            endmethod

            static method Get$name$ByHandle takes handle handleSource, integer key returns $type$
                return thistype.Get$name$(GetHandleId(handleSource), key)
            endmethod
        //! endtextmacro

        //! runtextmacro Memory_IntegerKeys_CreateType("Boolean", "boolean")
        //! runtextmacro Memory_IntegerKeys_CreateType("Integer", "integer")
        //! runtextmacro Memory_IntegerKeys_CreateType("Real", "real")
        //! runtextmacro Memory_IntegerKeys_CreateType("String", "string")

        static method Init takes nothing returns nothing
            set CACHE = HashTable.Create()
        endmethod
    endstruct

    //! runtextmacro Folder("StringKeys")
        //! runtextmacro Struct("Table")
            static constant integer EMPTY = -1
            static constant integer STARTED = 0

            //! textmacro Memory_StringKeys_Table_CreateType takes name, type, bugConverter
                static method Count$name$s takes string missionKey, string key returns integer
                    return (thistype.EMPTY + Memory.StringKeys.GetInteger(missionKey, key))
                endmethod

                static method Get$name$ takes string missionKey, string key, integer index returns $type$
                    return Memory.StringKeys.Get$name$(missionKey, key + I2S(thistype.EMPTY + index + 2))
                endmethod

                static method Contains$name$ takes string missionKey, string key, $type$ value returns boolean
                    local integer iteration = thistype.Count$name$s(missionKey, key)

                    loop
                        exitwhen (iteration < thistype.STARTED)

                        exitwhen (thistype.Get$name$(missionKey, key, iteration) == value)

                        set iteration = iteration - 1
                    endloop

                    if (iteration < thistype.STARTED) then
                        return false
                    endif

                    return true
                endmethod

                static method Add$name$ takes string missionKey, string key, $type$ value returns boolean
                    local integer count = thistype.Count$name$s(missionKey, key) + 1

                    call Memory.StringKeys.SetInteger(missionKey, key, count - thistype.EMPTY)
                    call Memory.StringKeys.Set$name$(missionKey, key + I2S(thistype.EMPTY + count + 2), value)

                    return (count == thistype.STARTED)
                endmethod

                static method Remove$name$ takes string missionKey, string key, $type$ value returns boolean
                    local integer count = thistype.Count$name$s(missionKey, key)

                    local integer iteration = count

                    loop
debug                        exitwhen (iteration < thistype.STARTED)

                        exitwhen (thistype.Get$name$(missionKey, key, iteration) == value)

                        set iteration = iteration - 1
                    endloop

debug                    if (iteration < thistype.STARTED) then
debug                        call BJDebugMsg("Failed to remove "+$bugConverter$(value)+" from table "+key+" of missionKey "+missionKey+" ("+I2S(count)+")")
debug                    else
                    call Memory.StringKeys.Set$name$(missionKey, key + I2S(thistype.EMPTY + iteration + 2), thistype.Get$name$(missionKey, key, count))

                    set count = count - 1

                    call Memory.StringKeys.SetInteger(missionKey, key, count)
debug                    endif

                    return (count == thistype.EMPTY)
                endmethod

                static method Random$name$ takes string missionKey, string key, integer lowerBound, integer higherBound returns $type$
                    return thistype.Get$name$(missionKey, key, Math.RandomI(lowerBound, higherBound))
                endmethod

                static method Random$name$All takes string missionKey, string key returns $type$
                    return thistype.Random$name$(missionKey, key, thistype.STARTED, thistype.Count$name$s(missionKey, key))
                endmethod
            //! endtextmacro

            //! runtextmacro Memory_StringKeys_Table_CreateType("Boolean", "boolean", "B2S")
            //! runtextmacro Memory_StringKeys_Table_CreateType("Integer", "integer", "I2S")
            //! runtextmacro Memory_StringKeys_Table_CreateType("Real", "real", "R2S")
            //! runtextmacro Memory_StringKeys_Table_CreateType("String", "string", "")
        endstruct
    endscope

    //! runtextmacro Struct("StringKeys")
        static GameCache CACHE

        //! runtextmacro LinkToStaticStruct("StringKeys", "Table")

        static method RemoveChild takes string missionKey returns nothing
            call CACHE.RemoveMission(missionKey)
        endmethod

        //! textmacro Memory_StringKeys_CreateType takes name, type
            static method Set$name$ takes string missionKey, string key, $type$ value returns nothing
                call CACHE.$name$.Set(missionKey, key, value)
            endmethod

            static method Remove$name$ takes string missionKey, string key returns nothing
                call CACHE.$name$.Remove(missionKey, key)
            endmethod

            static method Get$name$ takes string missionKey, string key returns $type$
                return CACHE.$name$.Get(missionKey, key)
            endmethod
        //! endtextmacro

        //! runtextmacro Memory_StringKeys_CreateType("Boolean", "boolean")
        //! runtextmacro Memory_StringKeys_CreateType("Integer", "integer")
        //! runtextmacro Memory_StringKeys_CreateType("Real", "real")
        //! runtextmacro Memory_StringKeys_CreateType("String", "string")

        static method Init takes nothing returns nothing
            set CACHE = GameCache.Create()
        endmethod
    endstruct
endscope

//! runtextmacro StaticStruct("Memory")
    //! runtextmacro LinkToStaticStruct("Memory", "IntegerKeys")
    //! runtextmacro LinkToStaticStruct("Memory", "StringKeys")

    static method Init takes nothing returns nothing
        call IntegerKeys.Init()
        call StringKeys.Init()
    endmethod
endstruct

//! textmacro GetKey takes name
    static key $name$_BASE
    static constant integer $name$ = Math.Integer.MIN + $name$_BASE
//! endtextmacro

//! textmacro GetKeyArray takes name
    static key $name$_BASE

    static constant integer $name$ = Math.Integer.MIN + Memory.IntegerKeys.Table.OFFSET + $name$_BASE * Memory.IntegerKeys.Table.SIZE
//! endtextmacro

//! textmacro Data_Create takes baseType
    method Destroy takes nothing returns nothing
        call Memory.IntegerKeys.RemoveChild($baseType$(this).Id.Get())
    endmethod
//! endtextmacro

//! textmacro Data_Type_Create takes baseType, whichTypeName, whichType
    method Get takes integer key returns $whichType$
        return Memory.IntegerKeys.Get$whichTypeName$($baseType$(this).Id.Get(), key)
    endmethod

    method Remove takes integer key returns nothing
        call Memory.IntegerKeys.Remove$whichTypeName$($baseType$(this).Id.Get(), key)
    endmethod

    method Set takes integer key, $whichType$ value returns nothing
        call Memory.IntegerKeys.Set$whichTypeName$($baseType$(this).Id.Get(), key, value)
    endmethod
//! endtextmacro

//! textmacro Data_Table_Create takes baseType, whichTypeName, whichType
    method Contains takes integer key, $whichType$ value returns boolean
        return Memory.IntegerKeys.Table.Contains$whichTypeName$($baseType$(this).Id.Get(), key, value)
    endmethod

    method Count takes integer key returns integer
        return Memory.IntegerKeys.Table.Count$whichTypeName$s($baseType$(this).Id.Get(), key)
    endmethod

    method Get takes integer key, integer index returns $whichType$
        return Memory.IntegerKeys.Table.Get$whichTypeName$($baseType$(this).Id.Get(), key, index)
    endmethod

    method Clear takes integer key returns nothing
        call Memory.IntegerKeys.Table.Clear($baseType$(this).Id.Get(), key)
    endmethod

    method Remove takes integer key, $whichType$ value returns boolean
        return Memory.IntegerKeys.Table.Remove$whichTypeName$($baseType$(this).Id.Get(), key, value)
    endmethod

    method RemoveSorted takes integer key, $whichType$ value returns boolean
        return Memory.IntegerKeys.Table.RemoveSorted$whichTypeName$($baseType$(this).Id.Get(), key, value)
    endmethod

    method Add takes integer key, $whichType$ value returns boolean
        return Memory.IntegerKeys.Table.Add$whichTypeName$($baseType$(this).Id.Get(), key, value)
    endmethod

    method AddSorted takes integer key, $whichType$ value returns boolean
        return Memory.IntegerKeys.Table.AddSorted$whichTypeName$($baseType$(this).Id.Get(), key, value)
    endmethod

    method Random takes integer key, integer lowerBound, integer higherBound returns $whichType$
        return Memory.IntegerKeys.Table.Random$whichTypeName$($baseType$(this).Id.Get(), key, lowerBound, higherBound)
    endmethod

    method RandomAll takes integer key returns $whichType$
        return this.Random(key, Memory.IntegerKeys.Table.STARTED, this.Count(key))
    endmethod
//! endtextmacro

//! textmacro Data_String_Create
    static method Destroy takes string whichString returns nothing
        call Memory.StringKeys.RemoveChild(whichString)
    endmethod
//! endtextmacro

//! textmacro Data_String_Type_Create takes whichTypeName, whichType
    static method Get takes string whichString, integer key returns $whichType$
        return Memory.StringKeys.Get$whichTypeName$(whichString, Integer.ToString(key))
    endmethod

    static method Remove takes string whichString, integer key returns nothing
        call Memory.StringKeys.Remove$whichTypeName$(whichString, Integer.ToString(key))
    endmethod

    static method Set takes string whichString, integer key, $whichType$ value returns nothing
        call Memory.StringKeys.Set$whichTypeName$(whichString, Integer.ToString(key), value)
    endmethod
//! endtextmacro

//! textmacro Data_String_Table_Create takes whichTypeName, whichType
    static method Count takes string whichString, integer key returns integer
        return Memory.StringKeys.Table.Count$whichTypeName$s(whichString, Integer.ToString(key))
    endmethod

    static method Get takes string whichString, integer key, integer index returns $whichType$
        return Memory.StringKeys.Table.Get$whichTypeName$(whichString, Integer.ToString(key), index)
    endmethod

    static method Remove takes string whichString, integer key, $whichType$ value returns boolean
        return Memory.StringKeys.Table.Remove$whichTypeName$(whichString, Integer.ToString(key), value)
    endmethod

    static method Add takes string whichString, integer key, $whichType$ value returns boolean
        return Memory.StringKeys.Table.Add$whichTypeName$(whichString, Integer.ToString(key), value)
    endmethod

    static method Random takes string whichString, integer key, integer lowerBound, integer higherBound returns $whichType$
        return Memory.StringKeys.Table.Random$whichTypeName$(whichString, Integer.ToString(key), lowerBound, higherBound)
    endmethod

    static method RandomAll takes string whichString, integer key returns $whichType$
        return thistype.Random(whichString, key, Memory.IntegerKeys.Table.STARTED, thistype.Count(whichString, key))
    endmethod
//! endtextmacro