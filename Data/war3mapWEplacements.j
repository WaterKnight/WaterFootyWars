struct preplaced
implement Allocation
implement List
static thistype unit_1
static thistype unit_0
static thistype unit_2
static thistype unit_7
static thistype unit_3
static thistype unit_4
static thistype unit_12
static thistype unit_8
static thistype unit_10
static thistype unit_11
static thistype unit_6
static thistype unit_5
boolean enabled
integer ownerIndex
integer typeId
real x
real y
real angle
thistype waygateTarget
//! runtextmacro CreateList("UNITS")
static method createUnit takes boolean enabled, integer typeId, integer ownerIndex, real x, real y, real angle, thistype waygateTarget returns thistype
local thistype this = thistype.allocate()
set this.enabled = enabled
set this.ownerIndex = ownerIndex
set this.typeId = typeId
set this.x = x
set this.y = y
set this.angle = angle
set this.waygateTarget = waygateTarget
call thistype.UNITS_Add(this)
return this
endmethod
static method initUnits
set thistype.unit_1 = thistype.createUnit(true, 'sloc', 0, -1408, 2560, 4.710, NULL)
set thistype.unit_0 = thistype.createUnit(true, 'sloc', 1, -2432, 2432, 4.710, NULL)
set thistype.unit_2 = thistype.createUnit(true, 'sloc', 2, -2560, 1408, 4.710, NULL)
set thistype.unit_7 = thistype.createUnit(true, 'sloc', 3, -2560, -1408, 4.710, NULL)
set thistype.unit_3 = thistype.createUnit(true, 'sloc', 4, -2432, -2432, 4.710, NULL)
set thistype.unit_4 = thistype.createUnit(true, 'sloc', 5, -1408, -2560, 4.710, NULL)
set thistype.unit_12 = thistype.createUnit(true, 'sloc', 6, 1408, -2560, 4.710, NULL)
set thistype.unit_8 = thistype.createUnit(true, 'sloc', 11, 1408, 2560, 4.710, NULL)
set thistype.unit_10 = thistype.createUnit(true, 'sloc', 10, 2432, 2432, 4.710, NULL)
set thistype.unit_11 = thistype.createUnit(true, 'sloc', 9, 2560, 1408, 4.710, NULL)
set thistype.unit_6 = thistype.createUnit(true, 'sloc', 8, 2560, -1408, 4.710, NULL)
set thistype.unit_5 = thistype.createUnit(true, 'sloc', 7, 2432, -2432, 4.710, NULL)
endmethod
static thistype rect_AltarRectBlue
static thistype rect_AltarRectRed
static thistype rect_AltarRectTeal
static thistype rect_Center
static thistype rect_Destructable13
static thistype rect_Destructable14
static thistype rect_Destructable15
static thistype rect_Destructable17
static thistype rect_Destructable19
static thistype rect_Destructable21
static thistype rect_Destructable28
static thistype rect_Destructable30
static thistype rect_Destructable32
static thistype rect_Destructable33
static thistype rect_Destructable34
static thistype rect_Destructable35
static thistype rect_Destructable36
static thistype rect_Destructable37
static thistype rect_Destructable38
static thistype rect_Destructable48
static thistype rect_Destructable49
static thistype rect_Destructable50
static thistype rect_Destructable52
static thistype rect_Destructable53
static thistype rect_Destructable54
static thistype rect_Destructable56
static thistype rect_Destructable73
static thistype rect_Destructable74
static thistype rect_Destructable75
static thistype rect_Destructable76
static thistype rect_MasterWizard
static thistype rect_GoblinShop
static thistype rect_UnitShredder
static thistype rect_Harmagedon
static thistype rect_InnerPlay
static thistype rect_PeqqiBeast
static thistype rect_Tower
static thistype rect_Tower2
static thistype rect_WaterSound1
static thistype rect_WaterSound2
static thistype rect_WaterSound3
static thistype rect_WaterSound4
static thistype rect_Unmasked
static thistype rect_GoldTower
static thistype rect_GoldTower2
static thistype rect_Harmagedon2
static thistype rect_MercenaryCamp
static thistype rect_Market
static thistype rect_SecondhandDealer
static thistype rect_Base
static thistype rect_CreepsMercenaryCamp
static thistype rect_CreepsMarket
static thistype rect_Destructable23
static thistype rect_Pool
static thistype rect_CameraBounds
static thistype rect_Workshop
static thistype rect_Destructable83
static thistype rect_Destructable82
static thistype rect_Destructable81
static thistype rect_Destructable80
static thistype rect_Destructable79
static thistype rect_Destructable78
static thistype rect_Destructable77
static thistype rect_Destructable84
static thistype rect_Destructable85
static thistype rect_Destructable86
static thistype rect_Destructable87
static thistype rect_Destructable88
static thistype rect_Destructable89
static thistype rect_Destructable90
static thistype rect_Destructable91
static thistype rect_Destructable92
static thistype rect_Destructable93
static thistype rect_Destructable94
static thistype rect_Destructable95
static thistype rect_Destructable96
static thistype rect_Destructable97
static thistype rect_Destructable98
static thistype rect_Destructable99
static thistype rect_Destructable101
static thistype rect_Destructable100
static thistype rect_Destructable102
real minX
real minY
real maxX
real maxY
//! runtextmacro CreateList("RECTS")
static method createRect takes real minX, real maxX, real minY, real maxY returns thistype
local thistype this = thistype.allocate()
set this.minX = minX
set this.maxX = maxX
set this.minY = minY
set this.maxY = maxY
set this.x = (minX + maxX) / 2
set this.y = (minY + maxY) / 2
call this.RECTS_Add(this)
return this
endmethod
static method initRects
set thistype.rect_AltarRectBlue = thistype.createRect(-4672, -4544, 4544, 4672)
set thistype.rect_AltarRectRed = thistype.createRect(-3776, -3648, 4800, 4928)
set thistype.rect_AltarRectTeal = thistype.createRect(-4928, -4800, 3648, 3776)
set thistype.rect_Center = thistype.createRect(-1664, 1664, -1664, 1664)
set thistype.rect_Destructable13 = thistype.createRect(-3136, -3008, 768, 896)
set thistype.rect_Destructable14 = thistype.createRect(-3264, -3136, 768, 896)
set thistype.rect_Destructable15 = thistype.createRect(-3392, -3264, 768, 896)
set thistype.rect_Destructable17 = thistype.createRect(-3456, -3328, 896, 1024)
set thistype.rect_Destructable19 = thistype.createRect(-3456, -3328, 1024, 1152)
set thistype.rect_Destructable21 = thistype.createRect(-3456, -3328, 1152, 1280)
set thistype.rect_Destructable28 = thistype.createRect(-3456, -3328, 2688, 2816)
set thistype.rect_Destructable30 = thistype.createRect(-3456, -3328, 2816, 2944)
set thistype.rect_Destructable32 = thistype.createRect(-3456, -3328, 2944, 3072)
set thistype.rect_Destructable33 = thistype.createRect(-3328, -3200, 2944, 3072)
set thistype.rect_Destructable34 = thistype.createRect(-3072, -2944, 2944, 3072)
set thistype.rect_Destructable35 = thistype.createRect(-3072, -2944, 3200, 3328)
set thistype.rect_Destructable36 = thistype.createRect(-3072, -2944, 3328, 3456)
set thistype.rect_Destructable37 = thistype.createRect(-2944, -2816, 3328, 3456)
set thistype.rect_Destructable38 = thistype.createRect(-2816, -2688, 3328, 3456)
set thistype.rect_Destructable48 = thistype.createRect(-1408, -1280, 3328, 3456)
set thistype.rect_Destructable49 = thistype.createRect(-1280, -1152, 3328, 3456)
set thistype.rect_Destructable50 = thistype.createRect(-1152, -1024, 3328, 3456)
set thistype.rect_Destructable52 = thistype.createRect(-896, -768, 3264, 3392)
set thistype.rect_Destructable53 = thistype.createRect(-1024, -896, 3328, 3456)
set thistype.rect_Destructable54 = thistype.createRect(-896, -768, 3136, 3264)
set thistype.rect_Destructable56 = thistype.createRect(-896, -768, 3008, 3136)
set thistype.rect_Destructable73 = thistype.createRect(-3456, -3392, 768, 832)
set thistype.rect_Destructable74 = thistype.createRect(-3456, -3392, 832, 896)
set thistype.rect_Destructable75 = thistype.createRect(-896, -832, 3392, 3456)
set thistype.rect_Destructable76 = thistype.createRect(-832, -768, 3392, 3456)
set thistype.rect_MasterWizard = thistype.createRect(-3424, -3360, 3360, 3424)
set thistype.rect_GoblinShop = thistype.createRect(-3488, -3424, 2016, 2080)
set thistype.rect_UnitShredder = thistype.createRect(-2080, -2016, 3296, 3360)
set thistype.rect_Harmagedon = thistype.createRect(-1632, -1568, 1568, 1632)
set thistype.rect_InnerPlay = thistype.createRect(-3712, 3712, -3712, 3712)
set thistype.rect_PeqqiBeast = thistype.createRect(-2464, -2400, 2400, 2464)
set thistype.rect_Tower = thistype.createRect(-1088, -960, 3136, 3264)
set thistype.rect_Tower2 = thistype.createRect(-3264, -3136, 960, 1088)
set thistype.rect_WaterSound1 = thistype.createRect(-6144, -4096, -6144, 6144)
set thistype.rect_WaterSound2 = thistype.createRect(-6144, 6144, -6144, -4096)
set thistype.rect_WaterSound3 = thistype.createRect(4096, 6144, -6144, 6144)
set thistype.rect_WaterSound4 = thistype.createRect(-6144, 6144, 4096, 6144)
set thistype.rect_Unmasked = thistype.createRect(-4096, 4096, -4096, 4096)
set thistype.rect_GoldTower = thistype.createRect(-544, -480, 1504, 1568)
set thistype.rect_GoldTower2 = thistype.createRect(-1568, -1504, 480, 544)
set thistype.rect_Harmagedon2 = thistype.createRect(-3968, 3968, -3968, 3968)
set thistype.rect_MercenaryCamp = thistype.createRect(224, 288, 1632, 1696)
set thistype.rect_Market = thistype.createRect(-1696, -1632, 160, 224)
set thistype.rect_SecondhandDealer = thistype.createRect(-32, 32, 3168, 3232)
set thistype.rect_Base = thistype.createRect(-3712, -512, 512, 3712)
set thistype.rect_CreepsMercenaryCamp = thistype.createRect(-128, 128, 1408, 1664)
set thistype.rect_CreepsMarket = thistype.createRect(-1664, -1408, -128, 128)
set thistype.rect_Destructable23 = thistype.createRect(-3456, -3328, 1280, 1408)
set thistype.rect_Pool = thistype.createRect(-448, 448, 1344, 1984)
set thistype.rect_CameraBounds = thistype.createRect(-3200, 3200, -2944, 3328)
set thistype.rect_Workshop = thistype.createRect(-2080, -2016, 3424, 3488)
set thistype.rect_Destructable83 = thistype.createRect(-3456, -3392, 3008, 3072)
set thistype.rect_Destructable82 = thistype.createRect(-3456, -3392, 2944, 3008)
set thistype.rect_Destructable81 = thistype.createRect(-3456, -3392, 2880, 2944)
set thistype.rect_Destructable80 = thistype.createRect(-3456, -3392, 2816, 2880)
set thistype.rect_Destructable79 = thistype.createRect(-3456, -3392, 2752, 2816)
set thistype.rect_Destructable78 = thistype.createRect(-3456, -3392, 2688, 2752)
set thistype.rect_Destructable77 = thistype.createRect(-3456, -3392, 2624, 2688)
set thistype.rect_Destructable84 = thistype.createRect(-3392, -3328, 3008, 3072)
set thistype.rect_Destructable85 = thistype.createRect(-3328, -3264, 3008, 3072)
set thistype.rect_Destructable86 = thistype.createRect(-3264, -3200, 3008, 3072)
set thistype.rect_Destructable87 = thistype.createRect(-3200, -3136, 3008, 3072)
set thistype.rect_Destructable88 = thistype.createRect(-3072, -3008, 3136, 3200)
set thistype.rect_Destructable89 = thistype.createRect(-3072, -3008, 3200, 3264)
set thistype.rect_Destructable90 = thistype.createRect(-3072, -3008, 3264, 3328)
set thistype.rect_Destructable91 = thistype.createRect(-3072, -3008, 3328, 3392)
set thistype.rect_Destructable92 = thistype.createRect(-3072, -3008, 3392, 3456)
set thistype.rect_Destructable93 = thistype.createRect(-3008, -2944, 3392, 3456)
set thistype.rect_Destructable94 = thistype.createRect(-2944, -2880, 3392, 3456)
set thistype.rect_Destructable95 = thistype.createRect(-2880, -2816, 3392, 3456)
set thistype.rect_Destructable96 = thistype.createRect(-2816, -2752, 3392, 3456)
set thistype.rect_Destructable97 = thistype.createRect(-2752, -2688, 3392, 3456)
set thistype.rect_Destructable98 = thistype.createRect(-2688, -2624, 3392, 3456)
set thistype.rect_Destructable99 = thistype.createRect(-3136, -3072, 3008, 3072)
set thistype.rect_Destructable101 = thistype.createRect(-3072, -3008, 3072, 3136)
set thistype.rect_Destructable100 = thistype.createRect(-3136, -3072, 2944, 3008)
set thistype.rect_Destructable102 = thistype.createRect(-3008, -2944, 3072, 3136)
endmethod
endstruct