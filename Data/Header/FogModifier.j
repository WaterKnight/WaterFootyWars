//! runtextmacro Scope("FogModifier")
    globals
        fogmodifier TEMP_FOG_MODIFIER
    endglobals

    function CreateFogModifierCircleWJ takes player whichPlayer, fogstate whichFogState, real x, real y, real radius, boolean useSharedVision, boolean afterUnits returns fogmodifier
        local fogmodifier newFogModifier = CreateFogModifierRadius( whichPlayer, whichFogState, x, y, radius, useSharedVision, afterUnits )
        call AddObject( newFogModifier, "FogModifier" )
    ///    call AddSavedIntegerToTable( "Objects", "FogModifiers", newFogModifierId )
        set TEMP_FOG_MODIFIER = newFogModifier
        set newFogModifier = null
        return TEMP_FOG_MODIFIER
    endfunction

    function CreateFogModifierRectWJ takes player whichPlayer, fogstate whichFogState, rect whichRect, boolean useSharedVision, boolean afterUnits returns fogmodifier
        local fogmodifier newFogModifier = CreateFogModifierRect( whichPlayer, whichFogState, whichRect, useSharedVision, afterUnits )
        call AddObject( newFogModifier, "FogModifierRect" )
    ///    call AddSavedIntegerToTable( "Objects", "FogModifiers", newFogModifierId )
        set TEMP_FOG_MODIFIER = newFogModifier
        set newFogModifier = null
        return TEMP_FOG_MODIFIER
    endfunction

    function EnableFogModifierWJ takes fogmodifier whichFogModifier, boolean flag returns nothing
        if ( flag ) then
            call FogModifierStart( whichFogModifier )
        else
            call FogModifierStop( whichFogModifier )
        endif
    endfunction

    function DestroyFogModifierWJ takes fogmodifier whichFogModifier returns nothing
        ///call RemoveSavedIntegerFromTable( "Objects", "FogModifiers", whichFogModifierId )
        call RemoveObject( whichFogModifier, "FogModifier" )
        call DestroyFogModifier( whichFogModifier )
    endfunction
//! runtextmacro Endscope()