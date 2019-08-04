//TESH.scrollpos=0
//TESH.alwaysfold=0
//! runtextmacro Scope("Infocard")
    public function Start takes nothing returns nothing
        local quest newQuest
        local string s
        
        set newQuest = CreateQuestWJ()
        
        call QuestSetDescription( newQuest, "-c: show camera dialog (-c value)\n\n-cs x: set camera smoothing factor to x (standard x=1.20)\n\n-m x: change background music to x\n(values for x: arthas, bloodelf, comrade, confrontation, credits, darka, darkv, doom, elf1, elf2, elf3, elfd, elfv, elfx, heroic, human1, human2, human3, humand, humanv, humanx, illidan, orc, orc1, orc2, orc3, orcd, orcv, orcx, lich, main, mistery, naga, pursuit, tension, undead1, undead2, undead3, undeadd, undeadv, undeadx, war2, war3)\n\n-hints: toggle hints on/off\n\n-sfx: future special effects on/off" )
        call QuestSetIconPath( newQuest, "ReplaceableTextures\\CommandButtons\\BTNUnsummonBuilding.blp" )
        call QuestSetRequired( newQuest, true )
        call QuestSetTitle( newQuest, "Commands" )

        set newQuest = CreateQuestWJ()
        
        set s = "Development:\nWaterKnight"
        
        set s = s + "\n\n"
        
        set s = s + "Ideas:\nanXieTy\nDojo\nThe-Red-OrK\nWaterKnight"
        
        set s = s + "\n\n"
        
        set s = s + "Testers:\nDojo\nThe-Red-OrK\nFrotty"
        
        set s = s + "\n\n"
        
        set s = s + "Imported material:\nRegeneration graphics (original \"BasicEarthFlash\" and \"BasicWaterFlash\", slightly modified by me) - JetFangInferno\nSales aura caster graphic (original \"Capitalism Aura\") - General Frank\nWhip sound: http://ftp.tux.org/pub/X-Windows/games/freeciv/incoming/sounds/whip.wav\nRest from Blizzard (partly reworked by me)"
        
        set s = s + "\n\n"
        
        set s = s + "optimized by Wc3Optimizer and Widgetizer (except editor version)"
        
        set s = s + "\n\n"
        
        set s = s + "Project thread: http://warcraft.ingame.de/forum/showthread.php?s=&threadid=143691"
        
        call QuestSetDescription( newQuest, s )
        call QuestSetIconPath( newQuest, "ReplaceableTextures\\CommandButtons\\BTNStormEarth&Fire.blp" )
        call QuestSetRequired( newQuest, false )
        call QuestSetTitle( newQuest, "Credits" )
        set newQuest = null
    endfunction
//! runtextmacro Endscope()