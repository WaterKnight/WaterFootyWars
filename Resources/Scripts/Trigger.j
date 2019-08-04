//! runtextmacro Folder("Trigger")
    //! runtextmacro Struct("Id")
        //! runtextmacro GetKeyArray("KEY_ARRAY")

        //! runtextmacro CreateSimpleAddState("integer", "KEY_ARRAY + this")
    endstruct

    //! runtextmacro Folder("Data")
        //! runtextmacro Folder("Integer")
            //! runtextmacro Struct("Table")
                //! runtextmacro Data_Table_Create("Trigger", "Integer", "integer")
            endstruct
        endscope

        //! runtextmacro Struct("Boolean")
            //! runtextmacro Data_Type_Create("Trigger", "Boolean", "boolean")
        endstruct

        //! runtextmacro Struct("Integer")
            //! runtextmacro LinkToStruct("Integer", "Table")

            //! runtextmacro InitLinksToStruct_Start()
            //! runtextmacro InitLinksToStruct_NewMember("Table")
            //! runtextmacro InitLinksToStruct_Ending()

            //! runtextmacro Data_Type_Create("Trigger", "Integer", "integer")

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

        //! runtextmacro Data_Create("Trigger")

        static method Init takes nothing returns nothing
            call thistype.InitStructLinks()

            call thistype(NULL).Integer.Init()
        endmethod
    endstruct

    //! runtextmacro Folder("Event")
        //! runtextmacro Struct("Native")
            static method GetLearnedSpellId takes nothing returns integer
                return GetLearnedSkill()
            endmethod

            static method GetSpellId takes nothing returns integer
                return GetSpellAbilityId()
            endmethod

            static method GetDamage takes nothing returns real
                return GetEventDamage()
            endmethod

            static method GetTrigger takes nothing returns Trigger
                return Trigger.GetFromSelf(GetTriggeringTrigger())
            endmethod
        endstruct
    endscope

    //! runtextmacro Struct("Event")
        static real DAMAGE

        //! runtextmacro LinkToStruct("Event", "Native")

        //! runtextmacro InitLinksToStruct_Start()
        //! runtextmacro InitLinksToStruct_NewMember("Native")
        //! runtextmacro InitLinksToStruct_Ending()

        static method GetDamage takes nothing returns real
            return thistype.DAMAGE
        endmethod

        static method SetDamage takes real value returns nothing
            set thistype.DAMAGE = value
        endmethod

        static method Init takes nothing returns nothing
            call thistype.InitStructLinks()
        endmethod
    endstruct

    //! runtextmacro Struct("RegisterEvent")
        method DestructableDeath takes Destructable whichDestructable returns nothing
            call TriggerRegisterDeathEvent(Trigger(this).self, whichDestructable.self)
        endmethod

        method Dialog takes Dialog whichDialog returns nothing
            call TriggerRegisterDialogEvent(Trigger(this).self, whichDialog.self)
        endmethod

        method DummyUnit takes DummyUnit whichUnit, unitevent whichUnitEvent returns nothing
            call TriggerRegisterUnitEvent(Trigger(this).self, whichUnit.self, whichUnitEvent)
        endmethod

        method EnterRegion takes Region whichRegion, BoolExpr whichFilter returns nothing
            call TriggerRegisterEnterRegion(Trigger(this).self, whichRegion.self, whichFilter.self)
        endmethod

        method LeaveRegion takes Region whichRegion, BoolExpr whichFilter returns nothing
            call TriggerRegisterLeaveRegion(Trigger(this).self, whichRegion.self, whichFilter.self)
        endmethod

        method User takes User whichPlayer, playerevent whichPlayerEvent returns nothing
            local integer iteration

            if (whichPlayer == User.ANY) then
                set iteration = User.MAX_ID

                loop
                    call this.User(User.ALL[iteration], whichPlayerEvent)

                    set iteration = iteration - 1
                    exitwhen (iteration < ARRAY_MIN)
                endloop
            endif
            call TriggerRegisterPlayerEvent(Trigger(this).self, whichPlayer.self, whichPlayerEvent)
        endmethod

        method UserChat takes User whichPlayer, string input, boolean exactMatch returns nothing
            local integer iteration

            if (whichPlayer == User.ANY) then
                set iteration = User.MAX_ID

                loop
                    call this.UserChat(User.ALL[iteration], input, exactMatch)

                    set iteration = iteration - 1
                    exitwhen (iteration < ARRAY_MIN)
                endloop
            endif
            call TriggerRegisterPlayerChatEvent(Trigger(this).self, whichPlayer.self, input, exactMatch)
        endmethod

        method PlayerUnit takes User whichPlayer, playerunitevent whichPlayerUnitEvent, BoolExpr whichFilter returns nothing
            call TriggerRegisterPlayerUnitEvent(Trigger(this).self, whichPlayer.self, whichPlayerUnitEvent, whichFilter.self)
        endmethod

        method Unit takes Unit whichUnit, unitevent whichUnitEvent returns nothing
            call TriggerRegisterUnitEvent(Trigger(this).self, whichUnit.self, whichUnitEvent)
        endmethod
    endstruct
endscope

//! runtextmacro BaseStruct("Trigger", "TRIGGER")
    //! runtextmacro GetKey("KEY")

    triggeraction action = null
    string name
    trigger self

    //! runtextmacro LinkToStruct("Trigger", "Data")
    //! runtextmacro LinkToStruct("Trigger", "Event")
    //! runtextmacro LinkToStruct("Trigger", "Id")
    //! runtextmacro LinkToStruct("Trigger", "RegisterEvent")

    static method GetFromSelf takes trigger self returns thistype
        return Memory.IntegerKeys.GetIntegerByHandle(self, KEY)
    endmethod

    method Clear takes nothing returns nothing
        call TriggerRemoveAction(this.self, this.action)
    endmethod

    method Destroy takes nothing returns nothing
        local trigger self = this.self

        call this.deallocate()
        //call DestroyTrigger(self)
        call DisableTrigger(self)

        set self = null
    endmethod

    method AddCode takes code actionFunction returns nothing
        if (actionFunction != null) then
            set this.action = TriggerAddAction(this.self, actionFunction)
            set this.name = Integer.ToString(Code.GetId(actionFunction))
        endif
    endmethod

    method Run takes nothing returns nothing
        call TriggerExecute(this.self)
    endmethod

    static method Sleep takes real timeOut returns nothing
        call TriggerSleepAction(timeOut)
    endmethod

    static method Create takes nothing returns thistype
        local trigger self = CreateTrigger()
        local thistype this = thistype.allocate()

        set this.self = self
        call Memory.IntegerKeys.SetIntegerByHandle(self, KEY, this)

        set self = null

        return this
    endmethod

    static method CreateFromCode takes code action returns thistype
        local thistype this = thistype.Create()

        call this.AddCode(action)

        return this
    endmethod

    static method Init takes nothing returns nothing
        call thistype(NULL).Data.Init()
        call thistype(NULL).Event.Init()
    endmethod
endstruct