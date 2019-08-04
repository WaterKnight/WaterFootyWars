//! runtextmacro Folder("Constants")
    globals
        constant integer ARRAY_MAX = 8191
        constant integer ARRAY_MIN = 0
        constant integer COMMAND_FIELD_SIZE = 12
        constant integer HERO_INVENTORY_SPELL_ID = 'AInv'
        constant integer MAX_INVENTORY_SIZE = 6
        constant integer STRUCT_MAX = 8190
        constant integer STRUCT_MIN = 1

        constant integer ARRAY_EMPTY = ARRAY_MIN - 1
        constant integer STRUCT_BASE = STRUCT_MAX + 1
        constant integer STRUCT_EMPTY = STRUCT_MIN - 1

        constant integer NULL = STRUCT_EMPTY
        constant integer STRUCT_INVALID = STRUCT_EMPTY - 1
    endglobals
endscope