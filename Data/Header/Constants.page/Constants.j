scope Constants
    globals
        constant real CENTER_X = 0.
        constant real CENTER_Y = 0.
        constant real HINT_TEXT_DURATION = 12.
        constant real LIMIT_OF_DEATH = 0.405
        constant real LIMIT_OF_IMMORTALS = 1.
        constant integer NULL = 0
        constant integer STANDARD_CLIFF_LEVEL = 2
    endglobals
endscope

scope ErrorStrings
    globals
        public constant string ABILITY_DEACTIVATED = "Ability deactivated"
        public constant string ALREADY_BOMB = "Is already a bomb"
        public constant string ALREADY_FULL_LIFE = "Has already full life"
        public constant string ALREADY_FULL_MANA = "Has already full mana"
        public constant string CAN_NOT_HAVE_SOCKET = "Cannot be socled"
        public constant string EARLY_PROMOTION = "No targets were found that could be revaluated"
        public constant string HAS_ALREADY_SOCKET = "Is already socled"
        public constant string INVALID_TARGET = "Invalid target"
        public constant string NEEDS_MANA_POOL = "Requires manapool"
        public constant string NEEDS_RACE = "Choose your race first"
        public constant string NO_CORPSES_FOUND = "No usable corpses were found"
        public constant string NOT_ALLY = "Not on allies"
        public constant string NOT_ENEMY_MECHANICAL = "No mechanical targets that are hostile"
        public constant string NOT_HERO = "Not on heroes"
        public constant string NOT_ILLUSION = "Not on illusions"
        public constant string NOT_MECHANICAL = "No mechanical targets allowed"
        public constant string NOT_NEUTRAL = "Not on neutrals"
        public constant string NOT_SELF = "Not self"
        public constant string NOT_STRUCTURE = "Not on buildings"
        public constant string NOT_WARD = "Not on wards"
        public constant string ONLY_ALLY = "Must be casted on an allied unit"
        public constant string ONLY_GROUND = "Only ground entities"
        public constant string ONLY_ORGANIC = "Only organic entities"
        public constant string ONLY_SPAWNS = "Only castable on spawn units"
        public constant string ONLY_SPAWNS_OR_RESERVE = "Only castable on spawn units or Reserves"
        public constant string ONLY_TOWN_HALL = "Must be casted on a town hall"
        public constant string ONLY_YOUR_TOWN_HALL = "Only usable on your own town hall"
        public constant string SHOP_BELONGS_TO_ENEMY = "This shop belongs to your enemy"
        public constant string TARGET_IS_INVULNERABLE = "Target is invulnerable"
        public constant string TARGET_IS_MAGIC_IMMUNE = "Target is immune to magical spells"
        public constant string TARGET_TOO_CLOSE = "Target too close"
        public constant string TOO_LESS_GOLD = "Not enough gold"
        public constant string TOO_LESS_LIFE = "Not enough life"
        public constant string TOO_LESS_LUMBER = "Not enough lumber"
        public constant string TOO_LESS_MANA = "Not enough mana"
        public constant string TOO_LESS_SUPPLY = "Needs more supply"
        public constant string TOO_MIGHTY = "Too mighty"
        public constant string WHAT_ABOUT_RACE_FIRST = "This makes no sense"
    endglobals
endscope

scope ColorStrings
    globals
        public constant integer BODY_LENGTH = 8
        public constant string FOOTY_DARK = "|cff0077ff"
        public constant string FOOTY_LIGHT = "|cff00bbff"
        public constant string GOLD = "|cffffcc00"
        public constant string GREEN = "|cff00ff00"
        public constant string RED = "|cffff0000"
        public constant string RESET = "|r"
        public constant integer RESET_LENGTH = 2
        public constant string SET_DARK = "|cffba4200"
        public constant string SET_LIGHT = "|cffdc640f"
        public constant string START = "|c"
        public constant integer START_LENGTH = 2
        public constant string YELLOW = "|cffffff00"
    endglobals
endscope