//! runtextmacro BaseStruct("EventResponse", "EVENT_RESPONSE")
    Trigger action

    method Run takes nothing returns nothing
        call this.action.Run()
    endmethod

    static method Create takes code actionFunction returns thistype
        local Trigger action = Trigger.Create()
        local thistype this = thistype.allocate()

        set this.action = action
        call action.AddCode(actionFunction)

        return this
    endmethod
endstruct

//! runtextmacro BaseStruct("EventPriority", "EVENT_PRIORITY")
    static thistype AI
    static thistype array ALL
    static integer ALL_AMOUNT
    static integer ALL_COUNT = ARRAY_EMPTY
    static thistype COMBINATION
    static thistype CONTENT
    static thistype CONTENT2
    static thistype EVENTS
    static thistype HEADER
    static thistype ITEMS
    static thistype MISC
    static thistype MISC2
    static thistype SPEECHES
    static thistype SPELLS
    static thistype UNIT_TYPES

    static method Create takes nothing returns thistype
        local thistype this = thistype.allocate()

        set thistype.ALL_COUNT = thistype.ALL_COUNT + 1

        set thistype.ALL[thistype.ALL_COUNT] = this

        return this
    endmethod

    static method Init takes nothing returns nothing
        set thistype.HEADER = thistype.Create()

        set thistype.COMBINATION = thistype.Create()

        set thistype.AI = thistype.Create()

        set thistype.EVENTS = thistype.Create()
        set thistype.CONTENT = thistype.Create()

        set thistype.CONTENT2 = thistype.Create()

        set thistype.ITEMS = thistype.CONTENT
        set thistype.MISC = thistype.CONTENT
        set thistype.MISC2 = thistype.CONTENT2
        set thistype.SPEECHES = thistype.CONTENT
        set thistype.SPELLS = thistype.CONTENT
        set thistype.UNIT_TYPES = thistype.CONTENT

        set thistype.ALL_AMOUNT = thistype.ALL_COUNT + 1
    endmethod
endstruct

//! runtextmacro BaseStruct("EventType", "EVENT_TYPE")
    static thistype ACQUIRES_TARGET
    static thistype ACT_ENDING
    static thistype ACT_START
    static thistype AFTER_INTRO
    static thistype AFTER_INTRO_FOR_PLAYER
    static thistype ATTACK
    static thistype ATTACK_AS_TARGET
    static thistype ATTACK_GROUND
    static thistype CHAT
    static thistype COOLDOWN_ENDING
    static thistype COOLDOWN_REFRESH
    static thistype COOLDOWN_START
    static thistype CREATE
    static thistype DAMAGE
    static thistype DAMAGE_AS_DAMAGER
    static thistype DAMAGE_EDIT
    static thistype DEATH
    static thistype DEATH_AS_KILLER
    static thistype DESTROY
    static thistype DISPEL
    static thistype DISPEL_NEGATIVE
    static thistype DISPEL_POSITIVE
    static thistype END_CAST
    static thistype ENTER
    static thistype HERO_PICK
    static thistype IDLE_ENDING
    static thistype IDLE_INTERVAL
    static thistype IDLE_START
    static thistype ITEM_CHARGES_AMOUNT_CHANGE
    static thistype ITEM_DROP
    static thistype ITEM_MOVE_INVENTORY
    static thistype ITEM_PICK_UP
    static thistype ITEM_POWER_UP_USE
    static thistype ITEM_SELL
    static thistype LEARN
    static thistype LEAVE
    static thistype LEVEL_ENDING
    static thistype LEVEL_START
    static thistype LIFE
    static thistype MANA
    static thistype MOVE_ENDING
    static thistype MOVE_INTERVAL
    static thistype MOVE_START
    static thistype ORDER
    static thistype ORDER_POINT
    static thistype ORDER_TARGET
    static thistype ORDER_TARGET_AS_TARGET
    static thistype REVIVE
    static thistype SPAWN
    static thistype SPELL_BEGIN
    static thistype SPELL_EFFECT
    static thistype START
    static thistype UNLEARN

    static method Create takes nothing returns thistype
        return thistype.allocate()
    endmethod

    static method Init takes nothing returns nothing
        set thistype.ACQUIRES_TARGET = thistype.Create()
        set thistype.ACT_ENDING = thistype.Create()
        set thistype.ACT_START = thistype.Create()
        set thistype.AFTER_INTRO = thistype.Create()
        set thistype.AFTER_INTRO_FOR_PLAYER = thistype.Create()
        set thistype.ATTACK = thistype.Create()
        set thistype.ATTACK_AS_TARGET = thistype.Create()
        set thistype.ATTACK_GROUND = thistype.Create()
        set thistype.CHAT = thistype.Create()
        set thistype.COOLDOWN_ENDING = thistype.Create()
        set thistype.COOLDOWN_REFRESH = thistype.Create()
        set thistype.COOLDOWN_START = thistype.Create()
        set thistype.CREATE = thistype.Create()
        set thistype.DAMAGE = thistype.Create()
        set thistype.DAMAGE_AS_DAMAGER = thistype.Create()
        set thistype.DAMAGE_EDIT = thistype.Create()
        set thistype.DEATH = thistype.Create()
        set thistype.DEATH_AS_KILLER = thistype.Create()
        set thistype.DESTROY = thistype.Create()
        set thistype.DISPEL = thistype.Create()
        set thistype.DISPEL_NEGATIVE = thistype.Create()
        set thistype.DISPEL_POSITIVE = thistype.Create()
        set thistype.END_CAST = thistype.Create()
        set thistype.ENTER = thistype.Create()
        set thistype.HERO_PICK = thistype.Create()
        set thistype.IDLE_ENDING = thistype.Create()
        set thistype.IDLE_INTERVAL = thistype.Create()
        set thistype.IDLE_START = thistype.Create()
        set thistype.ITEM_CHARGES_AMOUNT_CHANGE = thistype.Create()
        set thistype.ITEM_DROP = thistype.Create()
        set thistype.ITEM_MOVE_INVENTORY = thistype.Create()
        set thistype.ITEM_PICK_UP = thistype.Create()
        set thistype.ITEM_POWER_UP_USE = thistype.Create()
        set thistype.ITEM_SELL = thistype.Create()
        set thistype.LEARN = thistype.Create()
        set thistype.LEAVE = thistype.Create()
        set thistype.LEVEL_ENDING = thistype.Create()
        set thistype.LEVEL_START = thistype.Create()
        set thistype.LIFE = thistype.Create()
        set thistype.MANA = thistype.Create()
        set thistype.MOVE_ENDING = thistype.Create()
        set thistype.MOVE_INTERVAL = thistype.Create()
        set thistype.MOVE_START = thistype.Create()
        set thistype.ORDER = thistype.Create()
        set thistype.ORDER_POINT = thistype.Create()
        set thistype.ORDER_TARGET = thistype.Create()
        set thistype.ORDER_TARGET_AS_TARGET = thistype.Create()
        set thistype.REVIVE = thistype.Create()
        set thistype.SPAWN = thistype.Create()
        set thistype.SPELL_BEGIN = thistype.Create()
        set thistype.SPELL_EFFECT = thistype.Create()
        set thistype.START = thistype.Create()
        set thistype.UNLEARN = thistype.Create()
    endmethod
endstruct

//! runtextmacro Folder("Event")
    //! runtextmacro Struct("Id")
        //! runtextmacro GetKeyArray("KEY_ARRAY")

        //! runtextmacro CreateSimpleAddState("integer", "KEY_ARRAY + this")
    endstruct

    //! runtextmacro Folder("Data")
        //! runtextmacro Folder("Integer")
            //! runtextmacro Struct("Table")
                //! runtextmacro Data_Table_Create("Event", "Integer", "integer")
            endstruct
        endscope

        //! runtextmacro Struct("Boolean")
            //! runtextmacro Data_Type_Create("Event", "Boolean", "boolean")
        endstruct

        //! runtextmacro Struct("Integer")
            //! runtextmacro LinkToStruct("Integer", "Table")

            //! runtextmacro InitLinksToStruct_Start()
            //! runtextmacro InitLinksToStruct_NewMember("Table")
            //! runtextmacro InitLinksToStruct_Ending()

            //! runtextmacro Data_Type_Create("Event", "Integer", "integer")

            static method Init takes nothing returns nothing
                call thistype.InitStructLinks()
            endmethod
        endstruct
    endscope

    //! runtextmacro Struct("Data")
        //! runtextmacro LinkToStruct("Data", "Boolean")
        //! runtextmacro LinkToStruct("Data", "Integer")

        //! runtextmacro InitLinksToStruct_Start()
        //! runtextmacro InitLinksToStruct_NewMember("Boolean")
        //! runtextmacro InitLinksToStruct_NewMember("Integer")
        //! runtextmacro InitLinksToStruct_Ending()

        //! runtextmacro Data_Create("Event")

        static method Init takes nothing returns nothing
            call thistype.InitStructLinks()

            call thistype(NULL).Integer.Init()
        endmethod
    endstruct

    //! runtextmacro Struct("Limit")
        integer value
        limitop whichOperator

        method GetValue takes nothing returns integer
            return this.value
        endmethod

        method GetOperator takes nothing returns limitop
            return this.whichOperator
        endmethod

        method Is takes nothing returns boolean
            return (this.whichOperator != null)
        endmethod

        method Set takes integer value, limitop whichOperator returns nothing
            set this.value = value
            set this.whichOperator = whichOperator
        endmethod

        method Start takes nothing returns nothing
            set this.value = 0
            set this.whichOperator = null
        endmethod

        static method Init takes nothing returns nothing
            
        endmethod
    endstruct
endscope

//! runtextmacro BaseStruct("Event", "EVENT")
    //! runtextmacro GetKey("KEY")
    static constant integer KEY_ARRAY = 1
    //! runtextmacro GetKey("STATICS_PARENT_KEY")
    static integer SUBJECT_ID
    static thistype TRIGGER

    Trigger action
    real limitValue
    integer priority
    EventResponse response
    BoolExpr whichConditions
    limitop whichOperator
    integer whichType

    //! runtextmacro LinkToStruct("Event", "Data")
    //! runtextmacro LinkToStruct("Event", "Id")
    //! runtextmacro LinkToStruct("Event", "Limit")

    method GetAction takes nothing returns Trigger
        return this.action
    endmethod

    static method GetFromAction takes Trigger action returns thistype
        return action.Data.Integer.Get(KEY)
    endmethod

    method GetConditions takes nothing returns BoolExpr
        return this.whichConditions
    endmethod

    method GetPriority takes nothing returns integer
        return this.priority
    endmethod

    method GetResponse takes nothing returns EventResponse
        return this.response
    endmethod

    static method GetSubjectId takes nothing returns integer
        return thistype.SUBJECT_ID
    endmethod

    static method GetTrigger takes nothing returns thistype
        return thistype.TRIGGER
    endmethod

    method GetType takes nothing returns integer
        return this.whichType
    endmethod

    method Destroy takes nothing returns nothing
        call this.deallocate()
    endmethod

    static method GetKey takes EventType whichType, EventPriority priority returns integer
        return (KEY_ARRAY + Memory.IntegerKeys.Table.SIZE * ((whichType - 1) * EventPriority.ALL_AMOUNT + (priority - 1)))
    endmethod

    method CountEvents takes EventType whichType, EventPriority priority returns integer
        return Event(this).Data.Integer.Table.Count(Event.GetKey(whichType, priority))
    endmethod

    method GetEvent takes EventType whichType, EventPriority priority, integer index returns Event
        return Event(this).Data.Integer.Table.Get(Event.GetKey(whichType, priority), index)
    endmethod

    method RemoveEvent takes Event whichEvent returns nothing
        call Event(this).Data.Integer.Table.Remove(Event.GetKey(whichEvent.GetType(), whichEvent.GetPriority()), whichEvent)
    endmethod

    method AddEvent takes Event whichEvent returns nothing
        call Event(this).Data.Integer.Table.Add(Event.GetKey(whichEvent.GetType(), whichEvent.GetPriority()), whichEvent)
    endmethod

    static method CountAtStatics takes integer whichType, integer priority returns integer
        return Memory.IntegerKeys.Table.CountIntegers(STATICS_PARENT_KEY, GetKey(whichType, priority))
    endmethod

    static method GetFromStatics takes integer whichType, integer priority, integer index returns thistype
        return Memory.IntegerKeys.Table.GetInteger(STATICS_PARENT_KEY, GetKey(whichType, priority), index)
    endmethod

    method AddToStatics takes nothing returns nothing
        call Memory.IntegerKeys.Table.AddInteger(STATICS_PARENT_KEY, GetKey(this.whichType, this.priority), this)
    endmethod

    static method SetTrigger takes thistype this returns nothing
        set thistype.TRIGGER = this
    endmethod

    method Run takes nothing returns nothing
        call thistype.SetTrigger(this)

        if (this.GetConditions().Run()) then
            call this.GetAction().Run()
        endif
    endmethod

    method SetAction takes code actionFunction returns nothing
        local Trigger action = this.GetAction()

        if (action != NULL) then
            call action.Clear()
        endif
        call action.Data.Integer.Set(KEY, this)
        call action.AddCode(actionFunction)
    endmethod

    method SetConditions takes BoolExpr whichConditions returns nothing
        set this.whichConditions = whichConditions
    endmethod

    method SetResponse takes EventResponse response returns nothing
        set this.response = response
    endmethod

    static method SetSubjectId takes integer id returns nothing
        set thistype.SUBJECT_ID = id
    endmethod

    static method Create takes EventType whichType, EventPriority priority, code actionFunction returns thistype
        local Trigger action = Trigger.Create()
        local thistype this = thistype.allocate()

        set this.action = action
        set this.priority = priority
        set this.whichConditions = NULL
        set this.whichType = whichType
        call this.Id.Start()
        call this.Limit.Start()
        call this.SetAction(actionFunction)

        return this
    endmethod

    static method CreateLimit takes integer whichType, integer priority, integer value, limitop whichOperator, code actionFunction returns thistype
        local thistype this = thistype.Create(whichType, priority, actionFunction)

        call this.Limit.Set(value, whichOperator)

        return this
    endmethod

    static method Init takes nothing returns nothing
        call thistype(NULL).Data.Init()

        call EventPriority.Init()
        call EventType.Init()
    endmethod
endstruct