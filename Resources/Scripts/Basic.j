function B2I takes boolean b returns integer
    if b then
        return 1
    endif
    return 0
endfunction

function B2S takes boolean b returns string
    if b then
        return "true"
    endif
    return "false"
endfunction

//! textmacro Folder takes name
    scope Folder$name$
//! endtextmacro

//! textmacro LinkToStruct takes folder, name
    Folder$folder$_Struct$name$ $name$ = this
//! endtextmacro

//! textmacro LinkToNamedStruct takes folder, name
    Folder$folder$_$name$ $name$ = this
//! endtextmacro

globals
    trigger InitLinks_DUMMY_TRIGGER = CreateTrigger()
    integer InitLinks_ITERATION
    integer InitLinks_THREAD_BREAK_COUNTER
endglobals

//! textmacro InitLinksToStruct_Start
    static method InitLinks takes nothing returns nothing
        local integer iteration = InitLinks_ITERATION

        loop
//! endtextmacro

//! textmacro InitLinksToStruct_NewMember takes name
    set thistype(iteration).$name$ = iteration
//! endtextmacro

//! textmacro InitLinksToStruct_Ending
            set iteration = iteration - 1

            exitwhen (iteration < NULL)

            set InitLinks_THREAD_BREAK_COUNTER = InitLinks_THREAD_BREAK_COUNTER + 1

            exitwhen (InitLinks_THREAD_BREAK_COUNTER > 5000)
        endloop

        if (iteration > STRUCT_EMPTY) then
            set InitLinks_ITERATION = iteration
            set InitLinks_THREAD_BREAK_COUNTER = 0
//call BJDebugMsg("test2")
            call TriggerExecute(InitLinks_DUMMY_TRIGGER)
debug        else
debug            set InitLinks_ITERATION = iteration
        endif
    endmethod

    static method InitStructLinks takes nothing returns nothing
        set InitLinks_ITERATION = STRUCT_MAX
        set InitLinks_THREAD_BREAK_COUNTER = 0

        call TriggerClearActions(InitLinks_DUMMY_TRIGGER)

        call TriggerAddAction(InitLinks_DUMMY_TRIGGER, function thistype.InitLinks)
//call BJDebugMsg("test3")
        call TriggerExecute(InitLinks_DUMMY_TRIGGER)

debug        if (InitLinks_ITERATION > 0) then
debug            call BJDebugMsg("InitLinks: thread break with " +I2S(InitLinks_ITERATION) +" in ")//+InitStructLinks.name)
debug        endif
    endmethod
//! endtextmacro

//! textmacro LinkToStaticStruct takes folder, name
    static Folder$folder$_Struct$name$ $name$ = NULL
//! endtextmacro

//! textmacro Struct takes name
    public struct Struct$name$
        static thistype THIS = STRUCT_BASE
//! endtextmacro

//! textmacro NamedStruct takes name
    public struct $name$
//! endtextmacro

//! textmacro CreateStructTypeVar takes modifiers, folder, type, tail
    $modifiers$ Folder$folder$_Struct$type$ $tail$
//! endtextmacro

//! textmacro BaseStruct takes name, base
    globals
        $name$ $base$ = STRUCT_BASE
    endglobals

    struct $name$
        static thistype THIS = STRUCT_BASE
//! endtextmacro

//! textmacro StaticStruct takes name
    struct $name$
//! endtextmacro

//! textmacro CreateSimpleAddState_NotAdd takes type, defaultValue
    $type$ value

    method Get takes nothing returns $type$
        return this.value
    endmethod

    method Set takes $type$ value returns nothing
        set this.value = value
    endmethod

    method Start takes nothing returns nothing
        call this.Set($defaultValue$)
    endmethod

    method Update takes nothing returns nothing
        call this.Set(this.Get())
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState_NotStart takes type
    $type$ value

    method Get takes nothing returns $type$
        return this.value
    endmethod

    method Set takes $type$ value returns nothing
        set this.value = value
    endmethod

    method Add takes $type$ value returns nothing
        call this.Set(this.Get() + value)
    endmethod

    method Subtract takes $type$ value returns nothing
        call this.Set(this.Get() - value)
    endmethod

    method Update takes nothing returns nothing
        call this.Set(this.Get())
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState_OnlyGet takes type
    $type$ value

    method Get takes nothing returns $type$
        return this.value
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState_OnlyStart takes defaultValue
    method Start takes nothing returns nothing
        set this.value = $defaultValue$
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState_OnlyAdd takes type, defaultValue
    method Add takes $type$ value returns nothing
        call this.Set(this.Get() + value)
    endmethod

    method Start takes nothing returns nothing
        call this.Set( $defaultValue$ )
    endmethod

    method Subtract takes $type$ value returns nothing
        call this.Set(this.Get() - value)
    endmethod

    method Update takes nothing returns nothing
        call this.Set(this.Get())
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState_OnlyAdd_NotStart takes type
    method Add takes $type$ value returns nothing
        call this.Set(this.Get() + value)
    endmethod

    method Subtract takes $type$ value returns nothing
        call this.Set(this.Get() - value)
    endmethod

    method Update takes nothing returns nothing
        call this.Set(this.Get())
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState_OnlyAdd_UsePreset takes type, presetValue, defaultValue
    method Add takes $type$ value returns nothing
        call this.Set(this.Get() + value)
    endmethod

    method Start takes nothing returns nothing
        set this.value = $presetValue$
        call this.Set( $defaultValue$ )
    endmethod

    method Subtract takes $type$ value returns nothing
        call this.Set(this.Get() - value)
    endmethod

    method Update takes nothing returns nothing
        call this.Set(this.Get())
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState_OnlyStart_UsePreset takes presetValue, defaultValue
    method Start takes nothing returns nothing
        set this.value = $presetValue$
        call this.Set($defaultValue$)
    endmethod
//! endtextmacro

//! textmacro CreateSimpleAddState takes type, defaultValue
    $type$ value

    method Get takes nothing returns $type$
        return this.value
    endmethod

    method Set takes $type$ value returns nothing
        set this.value = value
    endmethod

    method Add takes $type$ value returns nothing
        call this.Set(this.Get() + value)
    endmethod

    method Start takes nothing returns nothing
        call this.Set($defaultValue$)
    endmethod

    method Subtract takes $type$ value returns nothing
        call this.Set(this.Get() - value)
    endmethod

    method Update takes nothing returns nothing
        call this.Set(this.Get())
    endmethod
//! endtextmacro

//! textmacro CreateSimpleFlagState_NotStart
    boolean flag

    method Is takes nothing returns boolean
        return this.flag
    endmethod

    method Set takes boolean flag returns nothing
        set this.flag = flag
    endmethod
//! endtextmacro

//! textmacro CreateSimpleFlagState takes defaultValue
    boolean flag

    method Is takes nothing returns boolean
        return this.flag
    endmethod

    method Set takes boolean flag returns nothing
        set this.flag = flag
    endmethod

    method Start takes nothing returns nothing
        call this.Set($defaultValue$)
    endmethod
//! endtextmacro

//! textmacro CreateSimpleFlagCountState takes defaultValue
    integer flag

    method Get takes nothing returns integer
        return this.flag
    endmethod

    method Is takes nothing returns boolean
        return (this.flag > 0)
    endmethod

    method Set takes integer flag returns nothing
        set this.flag = flag
    endmethod

    method Remove takes nothing returns nothing
        call this.Set(this.Get() - 1)
    endmethod

    method Add takes nothing returns nothing
        call this.Set(this.Get() + 1)
    endmethod

    method Start takes nothing returns nothing
        call this.Set($defaultValue$)
    endmethod
//! endtextmacro

//! textmacro CreateSimpleFlagCountState_NotStart
    integer flag

    method Get takes nothing returns integer
        return this.flag
    endmethod

    method Is takes nothing returns boolean
        return (this.flag > 0)
    endmethod

    method Set takes integer flag returns nothing
        set this.flag = flag
    endmethod

    method Remove takes nothing returns nothing
        call this.Set(this.Get() - 1)
    endmethod

    method Add takes nothing returns nothing
        call this.Set(this.Get() + 1)
    endmethod
//! endtextmacro

//scope Base

globals
    boolean TEMP_BOOLEAN
    boolean TEMP_BOOLEAN2
    boolean TEMP_BOOLEAN3
    boolean TEMP_BOOLEAN4
    integer TEMP_INTEGER
    integer TEMP_INTEGER2
    integer TEMP_INTEGER3
    integer TEMP_INTEGER4
    real TEMP_REAL
    real TEMP_REAL2
    real TEMP_REAL3
    real TEMP_REAL4
    real TEMP_REAL5
    real TEMP_REAL6
endglobals