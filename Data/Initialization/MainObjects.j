//TESH.scrollpos=91
//TESH.alwaysfold=0
scope MainObjects
    struct BlockerPos
        real x
        real y
    endstruct

    struct TreePos
        real x
        real y
    endstruct

    globals
        group ALL_GROUP
        rect array ALTAR_RECTS
        rect BASE_RECT
        BlockerPos array BLOCKER_POSES
        integer BLOCKER_POSES_COUNT = -1
        rect CAMERA_BOUNDS_RECT
        rect CENTER_RECT
        rect CREEPS_MARKET_RECT
        rect CREEPS_MERCENARY_CAMP_RECT
        Unit FOUNTAIN
        rect GOBLIN_SHOP_RECT
        rect GOLD_TOWER_RECT
        rect GOLD_TOWER2_RECT
        rect INNER_PLAY_RECT
        real INNER_PLAY_RECT_MAX_X = 3712.
        real INNER_PLAY_RECT_MAX_Y = 3712.
        real INNER_PLAY_RECT_MIN_X = -3712.
        real INNER_PLAY_RECT_MIN_Y = -3712.
        rect MARKET_RECT
        rect MASTER_WIZARD_RECT
        rect MERCENARY_CAMP_RECT
        rect PLAY_RECT
        real PLAY_RECT_MAX_X = 5632.
        real PLAY_RECT_MAX_Y = 5632.
        real PLAY_RECT_MIN_X = -5632.
        real PLAY_RECT_MIN_Y = -5632.
        rect POOL_RECT
        rect SECONDHAND_DEALER_RECT
        rect TOWER_RECT
        rect TOWER2_RECT
        TreePos array TREE_POSES
        integer TREE_POSES_COUNT = -1
        rect UNIT_SHREDDER_RECT
        rect UNMASKED_RECT
        rect WORKSHOP_RECT
        unit WORLD_CASTER
        rect WORLD_RECT
        real WORLD_RECT_MAX_X = 6144.
        real WORLD_RECT_MAX_Y = 6144.
        real WORLD_RECT_MIN_X = -6144.
        real WORLD_RECT_MIN_Y = -6144.
    endglobals

    private function InitBlockerPos takes rect r returns nothing
        local BlockerPos d = BlockerPos.create()
        set BLOCKER_POSES_COUNT = BLOCKER_POSES_COUNT + 1
        set BLOCKER_POSES[BLOCKER_POSES_COUNT] = d
        set d.x = GetRectCenterX(r)
        set d.y = GetRectCenterY(r)
        call InitRect(r)
    endfunction

    private function InitTreePos takes rect r returns nothing
        local TreePos d = TreePos.create()
        set TREE_POSES_COUNT = TREE_POSES_COUNT + 1
        set TREE_POSES[TREE_POSES_COUNT] = d
        set d.x = GetRectCenterX(r)
        set d.y = GetRectCenterY(r)
        call InitRect(r)
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration

        //call CreatePlayers()

        set ALL_GROUP = CreateGroupWJ()
        set ALTAR_RECTS[0] = InitRect( gg_rct_AltarRectRed )
        set ALTAR_RECTS[1] = InitRect( gg_rct_AltarRectBlue )
        set ALTAR_RECTS[2] = InitRect( gg_rct_AltarRectTeal )
        set BASE_RECT = InitRect( gg_rct_Base )
        set CAMERA_BOUNDS_RECT = InitRect( gg_rct_CameraBounds )
        set CENTER_RECT = InitRect( gg_rct_Center )

        call InitBlockerPos( gg_rct_Destructable73 )
        call InitBlockerPos( gg_rct_Destructable74 )
        call InitBlockerPos( gg_rct_Destructable75 )
        call InitBlockerPos( gg_rct_Destructable76 )
        //call InitBlockerPos( gg_rct_Destructable77 )
        //call InitBlockerPos( gg_rct_Destructable78 )
        //call InitBlockerPos( gg_rct_Destructable79 )
        //call InitBlockerPos( gg_rct_Destructable80 )
        //call InitBlockerPos( gg_rct_Destructable81 )
        //call InitBlockerPos( gg_rct_Destructable82 )
        //call InitBlockerPos( gg_rct_Destructable83 )
        //call InitBlockerPos( gg_rct_Destructable84 )
        //call InitBlockerPos( gg_rct_Destructable85 )
        //call InitBlockerPos( gg_rct_Destructable86 )
        //call InitBlockerPos( gg_rct_Destructable87 )
        //call InitBlockerPos( gg_rct_Destructable88 )
        //call InitBlockerPos( gg_rct_Destructable89 )
        //call InitBlockerPos( gg_rct_Destructable90 )
        //call InitBlockerPos( gg_rct_Destructable91 )
        //call InitBlockerPos( gg_rct_Destructable92 )
        //call InitBlockerPos( gg_rct_Destructable93 )
        //call InitBlockerPos( gg_rct_Destructable94 )
        //call InitBlockerPos( gg_rct_Destructable95 )
        //call InitBlockerPos( gg_rct_Destructable96 )
        //call InitBlockerPos( gg_rct_Destructable97 )
        //call InitBlockerPos( gg_rct_Destructable98 )
        //call InitBlockerPos( gg_rct_Destructable99 )
        //call InitBlockerPos( gg_rct_Destructable100 )
        //call InitBlockerPos( gg_rct_Destructable101 )
        //call InitBlockerPos( gg_rct_Destructable102 )

        call InitTreePos( gg_rct_Destructable13 )
        call InitTreePos( gg_rct_Destructable14 )
        call InitTreePos( gg_rct_Destructable15 )
        call InitTreePos( gg_rct_Destructable17 )
        call InitTreePos( gg_rct_Destructable19 )
        call InitTreePos( gg_rct_Destructable21 )
        call InitTreePos( gg_rct_Destructable23 )
        call InitTreePos( gg_rct_Destructable28 )
        call InitTreePos( gg_rct_Destructable30 )
        call InitTreePos( gg_rct_Destructable32 )
        call InitTreePos( gg_rct_Destructable33 )
        call InitTreePos( gg_rct_Destructable34 )
        call InitTreePos( gg_rct_Destructable35 )
        call InitTreePos( gg_rct_Destructable36 )
        call InitTreePos( gg_rct_Destructable37 )
        call InitTreePos( gg_rct_Destructable38 )
        call InitTreePos( gg_rct_Destructable48 )
        call InitTreePos( gg_rct_Destructable49 )
        call InitTreePos( gg_rct_Destructable50 )
        call InitTreePos( gg_rct_Destructable52 )
        call InitTreePos( gg_rct_Destructable53 )
        call InitTreePos( gg_rct_Destructable54 )
        call InitTreePos( gg_rct_Destructable56 )

        set GOBLIN_SHOP_RECT = InitRect( gg_rct_GoblinShop )
        set GOLD_TOWER_RECT = InitRect( gg_rct_GoldTower )
        set GOLD_TOWER2_RECT = InitRect( gg_rct_GoldTower2 )
        set INNER_PLAY_RECT = InitRect( gg_rct_InnerPlay )
        set MASTER_WIZARD_RECT = InitRect( gg_rct_MasterWizard )
        if (GetRandomInt(0, 1) == 0) then
            set CREEPS_MARKET_RECT = InitRect( gg_rct_CreepsMercenaryCamp )
            set CREEPS_MERCENARY_CAMP_RECT = InitRect( gg_rct_CreepsMarket )
            set MARKET_RECT = InitRect( gg_rct_MercenaryCamp )
            set MERCENARY_CAMP_RECT = InitRect( gg_rct_Market )
        else
            set CREEPS_MARKET_RECT = InitRect( gg_rct_CreepsMarket )
            set CREEPS_MERCENARY_CAMP_RECT = InitRect( gg_rct_CreepsMercenaryCamp )
            set MARKET_RECT = InitRect( gg_rct_Market )
            set MERCENARY_CAMP_RECT = InitRect( gg_rct_MercenaryCamp )
        endif
        set PLAY_RECT = RectWJ( GetCameraBoundMinX() - GetCameraMargin( CAMERA_MARGIN_LEFT ), GetCameraBoundMinY() - GetCameraMargin( CAMERA_MARGIN_BOTTOM ), GetCameraBoundMaxX() + GetCameraMargin( CAMERA_MARGIN_RIGHT ), GetCameraBoundMaxY() + GetCameraMargin( CAMERA_MARGIN_TOP ) )
        set POOL_RECT = InitRect(gg_rct_Pool)
        set SECONDHAND_DEALER_RECT = InitRect(gg_rct_SecondhandDealer)
        set TOWER_RECT = InitRect( gg_rct_Tower )
        set TOWER2_RECT = InitRect( gg_rct_Tower2 )
        set UNIT_SHREDDER_RECT = InitRect( gg_rct_UnitShredder )
        set UNMASKED_RECT = InitRect( gg_rct_Unmasked )
        set WORKSHOP_RECT = InitRect( gg_rct_Workshop )
        set WORLD_CASTER = CreateUnitWJ( NEUTRAL_PASSIVE_PLAYER, 'n007', 0, 0, 0 )
        set WORLD_RECT = GetWorldBoundsWJ()
    endfunction
endscope