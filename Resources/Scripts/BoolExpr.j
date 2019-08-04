//! runtextmacro BaseStruct("BoolExpr", "BOOL_EXPR")
    //! runtextmacro GetKey("KEY")
    static HashTable TABLE
    static thistype DEFAULT_TRUE

    boolexpr self

    method Destroy takes nothing returns nothing
        local boolexpr self = this.self

        call this.deallocate()
        call DestroyBoolExpr(self)

        set self = null
    endmethod

    static method GetByAnd takes BoolExpr a, BoolExpr b returns thistype
        local thistype this = TABLE.Integer.Get(a, b)

        if (this == HASH_TABLE.Integer.DEFAULT_VALUE) then
            set this = thistype.allocate()

            set this.self = And(a.self, b.self)
            call TABLE.Integer.Set(a, b, this)
        endif

        return this
    endmethod

    static method GetFromFunction takes code whichFunction returns thistype
        local thistype this
        local integer whichFunctionId = Code.GetId(whichFunction)

        set this = TABLE.Integer.Get(whichFunctionId, KEY)

        if (this == HASH_TABLE.Integer.DEFAULT_VALUE) then
            set this = thistype.allocate()

            set this.self = Condition(whichFunction)
            call TABLE.Integer.Set(whichFunctionId, KEY, this)
        endif

        return this
    endmethod

    method GetSelf takes nothing returns boolexpr
        return this.self
    endmethod

    static method DefaultTrue takes nothing returns boolean
        return true
    endmethod

    method Run takes nothing returns boolean
        local boolean result
        local trigger whichTrigger

        if (this == NULL) then
            return true
        endif

        set whichTrigger = CreateTrigger()

        call TriggerAddCondition(whichTrigger, this.self)

        set result = TriggerEvaluate(whichTrigger)

        call DestroyTrigger(whichTrigger)

        set whichTrigger = null

        return result
    endmethod

    static method Init takes nothing returns nothing
        set thistype.TABLE = HashTable.Create()
        set thistype(NULL).self = null

        set thistype.DEFAULT_TRUE = BoolExpr.GetFromFunction( function thistype.DefaultTrue )
    endmethod
endstruct