//TESH.scrollpos=18
//TESH.alwaysfold=0
scope Destructables
    public function Init takes nothing returns nothing
        local DestructableType d

        globals
            constant integer BLOCKER_DESTRUCTABLE_ID = 'B002'
        endglobals

        // Blocker
        set d = InitDestructableTypeEx(BLOCKER_DESTRUCTABLE_ID)
        set d.scale = 1
        set d.variationsCount = 0

        globals
            constant integer FOREST_TREE_DESTRUCTABLE_ID = 'B001'
        endglobals

        // Forest - Tree
        set d = InitDestructableTypeEx(FOREST_TREE_DESTRUCTABLE_ID)
        set d.scale = 1
        set d.variationsCount = 1

        globals
            constant integer ICE_DESERT_ICICLE_DESTRUCTABLE_ID = 'B003'
        endglobals

        // Ice Desert - Icicle
        set d = InitDestructableTypeEx(ICE_DESERT_ICICLE_DESTRUCTABLE_ID)
        set d.scale = 0.9
        set d.variationsCount = 7

        globals
            constant integer TROPICS_TREE_DESTRUCTABLE_ID = 'B004'
        endglobals

        // Tropics - Tree
        set d = InitDestructableTypeEx(TROPICS_TREE_DESTRUCTABLE_ID)
        set d.scale = 1
        set d.variationsCount = 9

        globals
            constant integer HELL_TREE_DESTRUCTABLE_ID = 'B005'
        endglobals

        // Hell - Tree
        set d = InitDestructableTypeEx(HELL_TREE_DESTRUCTABLE_ID)
        set d.scale = 1
        set d.variationsCount = 7

        globals
            constant integer BARRENS_TREE_DESTRUCTABLE_ID = 'B000'
        endglobals

        // Barrens - Tree
        set d = InitDestructableTypeEx(BARRENS_TREE_DESTRUCTABLE_ID)
        set d.scale = 1
        set d.variationsCount = 9
    endfunction
endscope