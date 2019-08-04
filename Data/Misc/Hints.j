//TESH.scrollpos=61
//TESH.alwaysfold=0
//! runtextmacro Scope("Hints")
    globals
        private constant real DURATION = 15.
        private boolean array HIDDEN
        private string array HINTS
        private integer HINTS_COUNT = -1
        private constant real INTERVAL = 60.
        private timer INTERVAL_TIMER
    endglobals

    private function CreateHint takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        local integer random = GetRandomInt( 0, HINTS_COUNT )
        local player specificPlayer
        loop
            set specificPlayer = PlayerWJ( iteration )
            if ( HIDDEN[GetPlayerId(specificPlayer)] == false ) then
                call DisplayTextTimedWJ( ColorStrings_GOLD + "Hint " + I2S( random + 1 ) + " of " + I2S( HINTS_COUNT + 1 ) + " :" + ColorStrings_RESET + " " + HINTS[random], DURATION, specificPlayer )
                call PlaySoundFromTypeForPlayer( HINT_SOUND_TYPE, specificPlayer )
            endif
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set specificPlayer = null
    endfunction

    public function Chat takes string chatMessage, player whichPlayer returns nothing
        local integer whichPlayerId
        set chatMessage = StringCase( chatMessage, false )
        if ( chatMessage == "-hints" ) then
            set whichPlayerId = GetPlayerId(whichPlayer)
            set HIDDEN[whichPlayerId] = (HIDDEN[whichPlayerId] == false)
            if (HIDDEN[whichPlayerId]) then
                call DisplayTextTimedWJ( ColorStrings_RED + "No more hints shown to you." + ColorStrings_RESET, HINT_TEXT_DURATION, whichPlayer )
            else
                call DisplayTextTimedWJ( ColorStrings_GREEN + "Hints enabled again." + ColorStrings_RESET, HINT_TEXT_DURATION, whichPlayer)
            endif
        endif
    endfunction

    public function Start takes nothing returns nothing
        call TimerStart( CreateTimerWJ(), INTERVAL, true, function CreateHint )
    endfunction

    public function InitHint takes string text returns nothing
        set HINTS_COUNT = HINTS_COUNT + 1
        set HINTS[HINTS_COUNT] = text
    endfunction

    public function Init takes nothing returns nothing
        local integer iteration = MAX_PLAYER_INDEX
        loop
            set HIDDEN[iteration] = false
            set iteration = iteration - 1
            exitwhen ( iteration < 0 )
        endloop
        set INTERVAL_TIMER = CreateTimerWJ()
        call InitHint( "Special thanks goes to: anXieTy, Dojo, Quillraven und The-Red-OrK and to the thousands of Footies that lost their lives during the tests")
        call InitHint( "After the upgrade of the town hall the spawn changes to the new unit type. Training the old type once suffices to return to it." )
        call InitHint( "The unit types within a race have different qualifications and disadvantages. Not everytime the representatives of higher tiers are superior to the others. Mix your troups and match yourself to the situation!" )
        call InitHint( "Chat message \"-c\" calls a dialog that lets you set your camera zoom or directly call \"-c value\"." )
        call InitHint( "The master wizards in the edges of your bases, which allow you to cast special events, use a team-shared manapool. Administrate it wisely and coordinate it with your comrades or declare a commander at the beginning." )
        call InitHint( "In 6on6 games players of one edge form a team. Events that refer to a team accordingly only affect members of the own corner." )
        call InitHint( "The goal of the game is to destroy all enemy town halls before they have done this to yours. The extermination of the forces might be useful but is not demanded." )
    //    call InitHint( "The more spawns the player possesses the longer it takes for a new unit to appear. The time span increases with each units by two percent." )
        //call InitHint( "The arenas only differ in appearances." )
        //call InitHint( "Graphic weather effects can be turned on/off via chat input \"-w\"." )
        call InitHint( "By researches improved abilities show the bonus only on future castings. Afore the completion of the research applied spell do not get the benefits." )
        call InitHint( "Abilities that are supported by the attributes of a hero, obtain the bonuses because of their stats at the beginning of performing the skill. Later changes do not count." )
        //call InitHint( "The terrain your units stand on influences them. Grass heals and marble refreshes the mental energies. Buildings are only erectable on bricky grounds.\n(The denotations here match the forest tileset, it is analog to the equivalent tiles of the other sets)" )
        call InitHint( "Gold coins and runes vanish after resting " + I2S( R2I(SpecialDrops_DURATION) ) + " seconds on the ground." )
        call InitHint( "Not all abilities are of magical nature. There are skills that can hit structures or mechanicals or even magic immune units and spells that are just the other way around." )
        call InitHint( "Each " + I2S( R2I(ExtraGold_INTERVAL) ) + " seconds you are granted " + I2S( ExtraGold_BONUS_GOLD ) + " extra gold." )
        call InitHint( "The upper movement speed limit equals " + I2S( R2I( Unit_Speed_Speed_UPPER_CAP ) ) + ", the lower is " + I2S( R2I( Unit_Speed_Speed_LOWER_CAP ) ) + "." )
        call InitHint( "Spawns and Reserves are able to reach silver and gold state, which award them with boosted values, by defeating hostile units in fights. Silver requires two murders, gold needs four kills." )
        call InitHint( "This map has a lot of interface changes. They will not vanish with the game's end as \"Warcraft 3\" resets to the normal interface only upon restart. So games that you play after this might show another style than they used to if you do not relaunch the program." )
        call InitHint( "If you have a german keyboard and \"Windows XP\", and you want to change the key functionality to the english version, you can press Alt+Shift to achieve this." )
        call InitHint( "A Unit dies when its life becomes below or equal to 0.405, destructables and items from 0.401 downwards on." )
        call InitHint( "The central fountain actually sells items. It's a commercial wishing well." )
        call InitHint( "The tooltips of buyable objects show the normal purchasing price. The actual amount can be lowered by the 'Cash Discount' ability. I hope you can calculate." )
        call InitHint( "Thanks to problems concerning customizing shopping the refreshing display may vary from the the original progress. However, the angular speed you can see is right and it only affects visibility as the refresh is controlled by own timers." )
        call InitHint( "Besides mana, the fountain grants nearby heroes additional experience in intervals but this only works if there is no enemy unit in range." )
        call InitHint( "Race-specific researches are only available for one race. Nevertheless, general ones like 'Upgrade Speed' from Human that do not refer to a special unit also apply to the spawns of the other races." )
        call InitHint( "Market and mercenary camp randomly decide their position at the beginning of the game. So you may find them swapped from your previous experience." )
        call InitHint( "Please be so good and pay the hardly-used infocard (quest menu) a visit. You can also find a list of commands there that can do useful stuff like toggling these hints off." )
        //call InitHint( "All trees are made of gold and are invulnerable. They always grow again and can be harvested by workers." )
        call InitHint( "Texttags are limited to 100 simultaneous instances :(" )
        call InitHint( "The infoboard (multiboard) shows kills and deaths of players and hero kills/hero deaths in brackets." )
        call InitHint( "You are able to see the enemy's Master Wizard's mana." )
        call InitHint( "None of the units really die here. They only play a less harmful version of dodgeball and act like their corpses are decaying to show their passionate sportsmanship." )
        call InitHint( "Each unit is able to attack air. However, melee ground units only do a reduced damage of (" + I2S(R2I(Air_DAMAGE_FACTOR * 100)) + "%) to them." )
        call InitHint( "Reserve gnolls, steam tanks and glaive throwers are classified as summoned." )
        call InitHint( "Hiring workers costs a bit but using the skill 'Repair' does not require extra payment." )
        call InitHint( "Heroes are automatically ordered to revive when they die if the town hall is able to do so at this moment." )
        call InitHint( "Your team's master wizard obtains " + I2S(R2I(MasterWizard_BONUS_MANA_PER_KILL)) + " for each kill you do (excluded are summoned units)." )

        call InitHint( "There are "+I2S(HINTS_COUNT + 2) + " hints." )
    endfunction
//! runtextmacro Endscope()