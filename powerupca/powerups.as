// METADATA
String POWERUPS_VERSION = S_COLOR_MAGENTA + "Powerups: " + S_COLOR_WHITE + "v1";
String POWERUPS_AUTHOR = S_COLOR_MAGENTA + "Powerups: " + S_COLOR_WHITE + "algolineu";

int POWERUPS_randomInteger(int min, int max) { return min + rand() % (max - min + 1); }

array<int> POWERUPS_teamAlivePlayerList(int teamNum)
{
    Team @team = @G_GetTeam(teamNum);

    array<int> playerList;
    for (int i = 0; @team.ent(i) != null; i++) {
        if (!team.ent(i).isGhosting())
            playerList.insertLast(team.ent(i).playerNum);
    }
    return playerList;
};

int POWERUPS_randomPlayerNumTeam(int teamNum)
{
    array<int> playerList = POWERUPS_teamAlivePlayerList(teamNum);
    return playerList[POWERUPS_randomInteger(0, playerList.length() - 1)];
};

bool POWERUPS_isOnGround(Entity @ent) {

    Trace trace;
    Vec3 start = ent.origin;
    Vec3 end = start;

    Vec3 mins, maxs;
    ent.getSize(mins, maxs);

    end.z -= 1;
    trace.doTrace( start, mins, maxs, end, ent.entNum, MASK_SOLID );

    if ( trace.startSolid )
    {
        return false;
    }

    if ( trace.planeNormal.z < 0.1f )
    {
        return false;
    }

    return true;
};

void POWERUPS_dealDamageWithArmor(Entity @ent, float damage) {
    float armorAbsorb = damage * (2.0f / 3.0f);
    float healthDamage = damage * (1.0f / 3.0f);

    if (ent.client.armor > 0.0f)
    {
        if (ent.client.armor >= armorAbsorb)
        {
            ent.client.armor -= armorAbsorb;
        }
        else
        {
            float leftover = armorAbsorb - ent.client.armor;
            ent.client.armor = 0.0f;
            healthDamage += leftover;                       // spillover hits health
        }
    }

    ent.health -= healthDamage;
};


const int CS_HELPMESSAGES = CS_GENERAL + 128 + 128;

String POWERUPS_helpmsg_bind(String bind) {
    return S_COLOR_GREEN + bind + S_COLOR_WHITE;
}

enum PowerUpHelpMessages {
    POWERUP_HELPMESSAGE_CLASSACTION = 1,
    POWERUP_HELPMESSAGE_JETPACK,
    POWERUP_HELPMESSAGE_AIMBOT
};

enum keyBinds {
    KEY_FORWARD = 0,
    KEY_BACK,
    KEY_LEFT,
    KEY_RIGHT,
    KEY_ATTACK,
    KEY_JUMP,
    KEY_CROUCH,
    KEY_SPECIAL,

    KEY_TOTAL
};

enum PowerUpNumberType {
    POWERUP_NUMBERTYPE_NONE = 0,
    POWERUP_NUMBERTYPE_MULTIPLIER,
    POWERUP_NUMBERTYPE_PERCENT,
    POWERUP_NUMBERTYPE_NUMBER,
    POWERUP_NUMBERTYPE_INTEGER
};

enum PowerUpID {
    POWERUPID_NONE = 0,
    POWERUPID_SWAP,
    POWERUPID_INSTA,
    POWERUPID_VAMPIRE,
    POWERUPID_MAXSPEED,
    POWERUPID_DASH,
    POWERUPID_JUMP,
    POWERUPID_EXTRADMG,
    POWERUPID_JETPACK,
    POWERUPID_EXTRAKB,
    POWERUPID_LAUNCH,
    POWERUPID_INVISIBILITY,
    POWERUPID_QUAD,
    POWERUPID_IMMORTALITY,
    POWERUPID_PULL_TOWARDS,
    POWERUPID_INFINITE_AMMO,
    POWERUPID_PROJECTILESPEED,
    POWERUPID_FREEZE_ENEMIES,
    POWERUPID_AIMBOT,
    // POWERUPID_WALLHACK,
    POWERUPID_CLONE,
    POWERUPID_TELEPORTER,

    maxPowerupID
}

cPowerUp POWERUPS_getPowerUpByID(uint id)
{
    switch (id) {
        case POWERUPID_SWAP:             return cPowerUpSwap();
        case POWERUPID_INSTA:            return cPowerUpInsta();
        case POWERUPID_VAMPIRE:          return cPowerUpVampire();
        case POWERUPID_MAXSPEED:         return cPowerUpMaxSpeed();
        case POWERUPID_DASH:             return cPowerUpDashSpeed();
        case POWERUPID_JUMP:             return cPowerUpJumpSpeed();
        case POWERUPID_EXTRADMG:         return cPowerUpExtraDamage();
        case POWERUPID_JETPACK:          return cPowerUpJetpack();
        case POWERUPID_EXTRAKB:          return cPowerUpExtraKnockback();
        case POWERUPID_LAUNCH:           return cPowerUpLaunch();
        case POWERUPID_INVISIBILITY:     return cPowerUpInvisibility();
        case POWERUPID_QUAD:             return cPowerUpQuad();
        case POWERUPID_IMMORTALITY:      return cPowerUpImmortality();
        case POWERUPID_PULL_TOWARDS:     return cPowerUpPullTowards();
        case POWERUPID_INFINITE_AMMO:    return cPowerUpInfiniteAmmo();
        case POWERUPID_PROJECTILESPEED:  return cPowerUpProjectileSpeed();
        case POWERUPID_FREEZE_ENEMIES:   return cPowerUpFreezeEnemies();
        case POWERUPID_AIMBOT:           return cPowerUpAimbot();
        // case POWERUPID_WALLHACK:         return cPowerUpWallhack();
        case POWERUPID_CLONE:            return cPowerUpClone();
        case POWERUPID_TELEPORTER:       return cPowerUpTeleporter();

        default:                         return cPowerUpNone();
      }

}
array<int> chooseablePowerupList;


// TODO: Projectiles have different amounts of knockback - Scales with dmg
int POWERUPS_kb_amount_weapon(int weap)
{
    const int KB_GB = 50;
    const int KB_MG = 10;
    const int KB_RG = 7;
    const int KB_GL = 100;
    const int KB_RL = 100;
    const int KB_PG = 20;
    const int KB_LG = 14;
    const int KB_EB = 80;

    switch (weap) {
    case WEAP_GUNBLADE:
        return KB_GB;
    case 2:
        return KB_MG;
    case 3:
        return KB_RG;
    case 4:
        return KB_GL;
    case 5:
        return KB_RL;
    case 6:
        return KB_PG;
    case 7:
        return KB_LG;
    case 8:
        return KB_EB;

    default:
        return 0;
    }
};

bool POWERUPS_isSplashDamage(int weap, float damage)
{
    switch (weap) {
        case WEAP_GUNBLADE:
            if ( damage < 35.0f )
                return true;
            else
                return false;
        case WEAP_GRENADELAUNCHER:
        case WEAP_ROCKETLAUNCHER:
            if ( damage < 80.0f )
                return true;
            else
                return false;
        case WEAP_PLASMAGUN:
            if ( damage < 15.0f )
                return true;
            else
                return false;

        default: return false;
    }
}

bool POWERUPS_isKeyPressed(Client @client, uint key)
{
    return (int(client.pressedKeys) & (1 << key) == (1 << key));
};

String POWERUPS_formatStringWithFloat(String desc, array<float> ar, array<uint> numTypes)
{
    array<String> args;

    for (uint i = 0; i < ar.length(); ++i) {
        if (i >= 8)
            break;
        args.insertLast(POWERUPS_formatFloat(numTypes[i], ar[i]));
    }

    String formatted;

    if (args.length() == 0)
        formatted = desc;
    else if (args.length() == 1)
        formatted = StringUtils::Format(desc, args[0]);
    else if (args.length() == 2)
        formatted = StringUtils::Format(desc, args[0], args[1]);
    else if (args.length() == 3)
        formatted = StringUtils::Format(desc, args[0], args[1], args[2]);
    else if (args.length() == 4)
        formatted = StringUtils::Format(desc, args[0], args[1], args[2], args[3]);
    else if (args.length() == 5)
        formatted = StringUtils::Format(desc, args[0], args[1], args[2], args[3], args[4]);
    else if (args.length() == 6)
        formatted = StringUtils::Format(desc, args[0], args[1], args[2], args[3], args[4], args[5]);
    else if (args.length() == 7)
        formatted = StringUtils::Format(desc, args[0], args[1], args[2], args[3], args[4], args[5], args[6]);
    else
        formatted = StringUtils::Format(desc, args[0], args[1], args[2], args[3], args[4], args[5], args[6], args[7]);

    return formatted;
}

// const uint POWERUP_INVISIBLE_PMFEATS = PMFEAT_DEFAULT & ~(
//     PMFEAT_CROUCH
// );

const uint POWERUP_JETPACK_PMFEATS_NEGATE = (PMFEAT_CROUCH | PMFEAT_JUMP | PMFEAT_DASH | PMFEAT_WALLJUMP);

const uint POWERUP_FROZEN_PMFEATS_NEGATE = (PMFEAT_CROUCH | PMFEAT_JUMP | PMFEAT_DASH | PMFEAT_WALLJUMP);

const uint POWERUP_AIMBOT_PMFEATS_NEGATE = (PMFEAT_DASH | PMFEAT_WALLJUMP);

array<cPowerUp @> powerUp(maxClients);

String POWERUPS_formatFloat(uint randomNumType, float rand)
{
    String msg = "";
    switch (randomNumType) {
    case POWERUP_NUMBERTYPE_MULTIPLIER:
        msg += StringUtils::FormatFloat(rand, "0", 1, 1) + "x";
        break;

    case POWERUP_NUMBERTYPE_PERCENT:
        msg += StringUtils::FormatFloat(rand * 100, "0", 1, 0) + "%";
        break;

    case POWERUP_NUMBERTYPE_NUMBER:
        msg += StringUtils::FormatFloat(rand, "0", 1, 1);
        break;

    case POWERUP_NUMBERTYPE_INTEGER:
        msg += StringUtils::FormatFloat(rand, "0", 1, 0);
        break;

    default:
        break;
    }
    return msg;
}

class cPowerUp {
    uint powerupID;

    array<uint> randomNumberTypes;

    array<float> rands;
    array<float> randsMin;
    array<float> randsMax;

    uint cooldownLength;
    uint cooldownTime;

    bool ability;

    uint abilityLength;
    uint abilityTimeEnd;

    uint effects;

    String name;
    String color;
    String longDescription;
    String description;
    String messageFormat;

    uint helpMessage;

    int imageIndex;

    cPowerUp(uint id, int imin, array<float> randsMin, array<float> randsMax, array<uint> randNumTypes, float cdown, float abilLen, const String& n, const String& c, const String& ld, const String& d, const String& mf, uint hm = 0)
    {
        powerupID = id;
        imageIndex = imin;

        cooldownLength = rint(floor(cdown * 1000));
        cooldownTime = levelTime + cooldownLength;

        ability = false;
        abilityLength = rint(floor(abilLen * 1000));
        abilityTimeEnd = 0;

        effects = 0;
        this.randomNumberTypes = randNumTypes;
        this.randsMin = randsMin;
        this.randsMax = randsMax;
        this.rands = setUpRands(randsMin, randsMax);


        name = n;
        color = c;
        longDescription = ld;
        description = d;
        messageFormat = mf;
        helpMessage = hm;
    }

    void makeRands()
    {
        this.randomNumberTypes = { POWERUP_NUMBERTYPE_NONE };
        this.rands = { 0.0f };
        this.randsMin = { 0.0f };
        this.randsMax = { 0.0f };
    }

    void init(Entity @ent)
    {

        // G_Print(ent.client.name + " " + this.name + " " + this.rand + " " + (this.useRand2  ? this.rands[1] : "") + "\n");
        // G_Print(ent.client.name + " " + this.powerupMessage() + "\n");
        // G_CenterPrintMsg(ent, this.color + this.name + " " + this.rand + " " + this.rands[1] );
        if (this.powerupID != POWERUPID_NONE) {
            G_PrintMsg(ent, this.powerupMessage( "", true ) + "\n");
            G_CenterPrintMsg(ent, this.powerupMessage());
        }
        if (maxClients < 120) { // MAX_GENERAL = 128, MAX_CLIENTS = 256
            G_ConfigString(CS_GENERAL + 2 + ent.playerNum, this.statMessage());
            ent.client.setHUDStat(STAT_MESSAGE_SELF, CS_GENERAL + 2 + ent.playerNum);
            // ent.client.setHUDStat(STAT_IMAGE_SELF, this.imageIndex );
        }
        ent.client.setHelpMessage( 0 );
        ent.client.setHelpMessage( this.helpMessage + 1 );
    }

    array<float> setUpRands(array<float> minRands, array<float> maxRands)
    {
        if (minRands.length() != maxRands.length()) {
            G_Print(S_COLOR_YELLOW + "WARNING: minRands length != maxRands length\n");
            return { 0.0f };
        }

        array<float> randomNumbers(minRands.length());

        for (uint i = 0; i < minRands.length(); i++) {
            randomNumbers[i] = brandom(minRands[i], maxRands[i]);
        }
        return randomNumbers;
    };

    String statMessage()
    {
        String msg = this.color + this.name + S_COLOR_WHITE;

        String formatted = POWERUPS_formatStringWithFloat(this.messageFormat, this.rands, this.randomNumberTypes);
        msg += formatted;

        // msg += StringUtils::Format(this.messageFormat, POWERUPS_formatFloat(this.randomNumberType, this.rand), POWERUPS_formatFloat(this.randomNumberType, this.rands[1]));
        msg += S_COLOR_WHITE;
        return msg;
    };

    String powerupMessage( String statMessageReplacement = "", bool UseLongDescription = false )
    {
        String msg = ( statMessageReplacement.empty() ? statMessage() : statMessageReplacement ) + "\n";

        String formatted = POWERUPS_formatStringWithFloat( ( UseLongDescription ? this.longDescription : this.description ), this.rands, this.randomNumberTypes);
        msg += formatted;

        msg += S_COLOR_WHITE;
        return msg;
    };


    void select(Entity @ent) { }
    void clearPowerup(Entity @ent) { }

    void think(Entity @ent) { }
    void kill(Entity @ent, const String& in args = "") { }
    void dmg(Entity @ent, const String& in args = "") { }

    void tookdmg(Entity @ent, const String& in args = "") { }

    void classAction(Entity @ent) { }

    bool checkCooldown(Entity @ent)
    {
        if (ent.isGhosting())
            return false;
        if (this.cooldownTime > levelTime) {
            G_PrintMsg(ent, StringUtils::Format((this.color + this.name + S_COLOR_WHITE + " is on cooldown for %s more seconds\n"), StringUtils::FormatFloat(float(this.cooldownTime - levelTime) / 1000.0f, "0", 1, 1)));
            return false;
        }
        if (this.cooldownLength != 0)
            this.cooldownTime = levelTime + this.cooldownLength;
        return true;
    }

    float getCooldownFloat()
    {
        if (this.cooldownLength <= 0)
            return 0.0f;
        float cooldown = (float((levelTime + this.cooldownLength) - this.cooldownTime)) / this.cooldownLength;
        if (ability)
            cooldown = 1.0f - (float((levelTime + this.abilityLength) - this.abilityTimeEnd)) / this.abilityLength;

        if (cooldown <= 0.0f)
            cooldown = 0.0f;
        if (cooldown >= 1.0f)
            cooldown = 1.0f;
        return cooldown;
    };
    float getStatFloat()
    {
        return getCooldownFloat();
    };
};

class cPowerUpNone : cPowerUp {
    cPowerUpNone()
    {
        super(
            POWERUPID_NONE,
            0,

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            0.0f, 0.0f,

            "",
            S_COLOR_WHITE,
            "",
            "",
            ""
        );
    }
}

class cPowerUpSwap : cPowerUp {
    cPowerUpSwap()
    {
        super(
            POWERUPID_SWAP,
            G_ImageIndex("gfx/hud/icons/vsay/needbackup"),

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            10.0f, 0.0f,

            "Position Swap",
            S_COLOR_ORANGE,
            "Swap positions of yourself and the enemy furthest away from you.",
            "Swap positions of yourself and the enemy furthest away from you",
            "",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    void select(Entity @ent) override
    {
        POWERUPS_setUpClassaction(@ent, "Swap");
    }

    void classAction(Entity @ent) override
    {
        if (ent.health <= 0)
            return;
        if (!checkCooldown(@ent))
            return;

        int enemyTeam = ent.team == TEAM_ALPHA ? TEAM_BETA : TEAM_ALPHA;
        if (POWERUPS_teamAlivePlayerList(enemyTeam).length() == 0) {
            G_PrintMsg(ent, "Nobody on the enemy team is alive.\n");
            return;
        }

        Vec3 initiatorOrigin = ent.origin;
        Vec3 initiatorAngles = ent.angles;
        Vec3 initiatorVelocity = ent.velocity;

        Entity @targetEnt = null;
        float highestDistance = 0;

        for (int i = 0; i < maxClients; i++) {
            Entity @compareEnt = @G_GetClient(i).getEnt();
            if (ent.team == compareEnt.team)
                continue;
            if (compareEnt.isGhosting())
                continue;

            float distance = initiatorOrigin.distance(compareEnt.origin);

            if (distance > highestDistance) {
                highestDistance = distance;
                @targetEnt = @compareEnt;
            }
        }

        // remove all projectiles by the swapper, avoid someone spamming nades before swap to kill them
        array<String> projectile_classnames = { "rocket", "grenade", "plasma", "gunblade_blast" };
        for (uint j = 0; j < projectile_classnames.length(); j++) {
            array<Entity @> @ents = G_FindByClassname(projectile_classnames[j]);

            for (uint k = 0; k < ents.length(); k++) {
                if (@ents[k].owner != @ent)
                    continue;
                ents[k].freeEntity();
            }
        }

        Vec3 targetOrigin = targetEnt.origin;
        Vec3 targetAngles = targetEnt.angles;
        Vec3 targetVelocity = targetEnt.velocity;

        ent.origin = targetOrigin;
        ent.angles = targetAngles;
        ent.velocity = targetVelocity;

        targetEnt.origin = initiatorOrigin;
        targetEnt.angles = initiatorAngles;
        targetEnt.velocity = initiatorVelocity;

        G_PrintMsg(ent, "You swapped with " + targetEnt.client.name + "\n");
        G_PrintMsg(targetEnt, ent.client.name + S_COLOR_WHITE + " swapped with you" + "\n");
        G_CenterPrintMsg(ent, "You swapped with " + targetEnt.client.name);
        G_CenterPrintMsg(targetEnt, ent.client.name + S_COLOR_WHITE + " swapped with you");
        ent.teleportEffect( false );
        targetEnt.teleportEffect( false );
    }
}

class cPowerUpInsta : cPowerUp {
    cPowerUpInsta()
    {
        super(
            POWERUPID_INSTA,
            G_ImageIndex("gfx/hud/icons/weapon/instagun"),

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            0.0f, 0.0f,
            "Instagib",
            S_COLOR_MAGENTA,
            "You frag people in one hit, you only have 75 health and you have the same amount of bullets as there are enemies.",
            "You frag people in one hit, but you have low health",
            ""
        );
    }

    void select(Entity @ent) override
    {
        Team @team = @G_GetTeam(ent.team == TEAM_ALPHA ? TEAM_BETA : TEAM_ALPHA);
        int enemiesAlive = 0;
        for (int i = 0; @team.ent(i) != null; i++) {
            if (!team.ent(i).isGhosting())
                enemiesAlive++;
        }

        ent.client.inventoryClear();
        ent.client.inventorySetCount(WEAP_GUNBLADE, 1);
        ent.client.inventorySetCount(WEAP_INSTAGUN, 1);
        ent.client.inventorySetCount(AMMO_INSTAS, enemiesAlive);
        ent.client.armor = 0;
        ent.health = 75;
        ent.client.selectWeapon(-1);
    }
    void dmg(Entity @ent, const String& in args = "") override
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        // float damage = args.getToken( 1 ).toFloat();
        if (@victim.client == null)
            return;
        cPowerUp @pwr = @powerUp[victim.playerNum];
        if ( !( pwr.powerupID == POWERUPID_IMMORTALITY && pwr.ability ) )
            victim.health -= 9999;
        // make sure they die
    }

}

class cPowerUpVampire : cPowerUp {
    cPowerUpVampire()
    {
        super(
            POWERUPID_VAMPIRE,
            G_ImageIndex("gfx/hud/icons/classactions/medic1"),


            { 0.25f },
            { 1.00f },
            { POWERUP_NUMBERTYPE_PERCENT },

            0.0f, 0.0f,

            "Vampire",
            S_COLOR_GREY,
            "You gain %s of the damage you do, up to a maximum of 500 health.",
            "You gain %s of the damage you do",
            " - %s"
        );
    }

    float maxHealth = 500.0f;

    void select(Entity @ent) override
    {

        ent.health = 250;
        ent.maxHealth = 250;
        ent.client.armor = 0;
    };


    void dmg(Entity @ent, const String& in args = "") override
    {
        if (ent.health <= 0)
            return;
        if (@ent.client == null)
            return;

        float damage = args.getToken(1).toFloat();
        ent.health += (damage * this.rands[0]);
        if (ent.health >= this.maxHealth)
            ent.health = this.maxHealth;
    }
}

class cPowerUpMaxSpeed : cPowerUp {
    cPowerUpMaxSpeed()
    {
        super(
            POWERUPID_MAXSPEED,
            G_ImageIndex("gfx/hud/arrow"),

            { 2.0f },
            { 3.0f },
            { POWERUP_NUMBERTYPE_MULTIPLIER },

            0.0f, 0.0f,

            "Acceleration",
            S_COLOR_CYAN,
            "Your max speed is %s the normal amount, and you gain speed at a much faster rate.",
            "You accelerate %s faster",
            " - %s"
        );
    }

    void select(Entity @ent) override
    {
        ent.client.pmoveMaxSpeed = (320 * this.rands[0]);
    }
}

class cPowerUpDashSpeed : cPowerUp {
    cPowerUpDashSpeed()
    {
        super(
            POWERUPID_DASH,
            G_ImageIndex("gfx/dash/dash_burst_1"),

            { 2.0f },
            { 3.5f },
            { POWERUP_NUMBERTYPE_MULTIPLIER },

            0.0f, 0.0f,

            "Dash Speed",
            S_COLOR_CYAN,
            "Your dash brings you up to %s the speed the regular dash would.",
            "Your dash brings you up to %s the speed the regular dash would",
            " - %s"
        );
    }

    void select(Entity @ent) override
    {
        ent.client.pmoveDashSpeed = (450 * this.rands[0]);
    }
}

class cPowerUpJumpSpeed : cPowerUp {
    cPowerUpJumpSpeed()
    {
        super(
            POWERUPID_JUMP,
            G_ImageIndex("gfx/hud/icons/arrowmark"),

            { 1.25f },
            { 2.50f },
            { POWERUP_NUMBERTYPE_MULTIPLIER },

            0.0f, 0.0f,

            "Jump Height",
            S_COLOR_CYAN,
            "You jump %s higher.",
            "You jump %s higher",
            " - %s"
        );
    }

    void select(Entity @ent) override
    {
        ent.client.pmoveJumpSpeed = (280 * this.rands[0]);
    }
}

class cPowerUpExtraDamage : cPowerUp {
    cPowerUpExtraDamage()
    {
        super(
            POWERUPID_EXTRADMG,
            G_ImageIndex("gfx/hud/icons/vsay/boomstick"),

            { 0.20f },
            { 0.80f },
            { POWERUP_NUMBERTYPE_PERCENT },

            0.0f, 0.0f,

            "Extra Damage",
            S_COLOR_RED,
            "You deal %s more damage.",
            "You deal %s more damage",
            " - %s"
        );
    }

    void dmg(Entity @ent, const String& in args = "") override
    {

        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        float damage = args.getToken(1).toFloat();
        if (@victim.client == null)
            return;
        if (damage > victim.health + victim.client.armor)
            return;

        cPowerUp @pwr = @powerUp[victim.playerNum];
        if ( !( pwr.powerupID == POWERUPID_IMMORTALITY && pwr.ability ) )
            POWERUPS_dealDamageWithArmor(@victim, damage * this.rands[0]);
    }
};

class cPowerUpJetpack : cPowerUp {
    cPowerUpJetpack()
    {
        super(
            POWERUPID_JETPACK,
            0,                                              // TODO: NO IMAGE

            { 1.0f },
            { 2.0f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Jetpack",
            S_COLOR_GREEN,
            "You can fly by holding jump, you can boost by holding special and you can go down faster by holding crouch. Be wary of your fuel!",
            "You can fly by holding jump and boost by holding special.",
            " - Power: %s",
            POWERUP_HELPMESSAGE_JETPACK
        );
    }

    float fuelMax = 100.0f;
    float fuel = fuelMax;
    bool outOfFuel = false;
    bool lowOnFuel = false;

    uint regular_pmfeats;

    void select(Entity @ent) override
    {
        regular_pmfeats = ent.client.pmoveFeatures;
        ent.client.pmoveFeatures &= ~POWERUP_JETPACK_PMFEATS_NEGATE;
        this.fuel = this.fuelMax;
        ent.mass = rint(ent.mass * 1.5);
    };

    float getStatFloat() override
    {
        return (outOfFuel ? -1 : 1) * (this.fuel / this.fuelMax);
    };

    void think(Entity @ent) override
    {
        Vec3 newVelocity = ent.velocity;

        Vec3 mins, maxs;
        ent.getSize( mins, maxs );

        Trace trace;
        bool inWall = trace.doTrace(ent.origin, mins, maxs, ent.origin, ent.entNum, MASK_SOLID);

        if (inWall && ent.moveType != MOVETYPE_NOCLIP) {
            Vec3 newOrigin = ent.origin;
            uint i = 0;

            while (trace.doTrace(newOrigin, mins, maxs, newOrigin, ent.entNum, MASK_SOLID)) {
                newOrigin.z -= 0.5f;
                i++;
                if (i > 100) {
                    G_Print(S_COLOR_RED + "ERROR:" + S_COLOR_WHITE + ent.client.name + S_COLOR_RED + " got stuck in a wall!\n");
                    G_PrintMsg(ent, S_COLOR_RED + "You got stuck in a wall/ceiling and died.\n");
                    ent.sustainDamage(@ent, @ent, Vec3(0, 0, 0), 9999, 0, 0, MOD_SUICIDE);
                    break;
                }
            }

            ent.origin = newOrigin;
        }
        if (fuel > 0.0f && !outOfFuel) {
            if (POWERUPS_isKeyPressed(ent.client, KEY_JUMP)) {

                if ( POWERUPS_isOnGround( @ent ) ) {
                    Vec3 newOrigin = ent.origin;
                    newOrigin.z += 0.5f;
                    ent.origin = newOrigin;
                }

                this.fuel -= 7.5 * (frameTime * 0.001f);

                newVelocity.z += (this.rands[0] + 15.0f);
                ent.velocity = newVelocity;
            }
            if (POWERUPS_isKeyPressed(ent.client, KEY_CROUCH)) {
                newVelocity.z -= 10;
                ent.velocity = newVelocity;
                this.fuel -= 2.5 * (frameTime * 0.001f);
            }
            if (POWERUPS_isKeyPressed(ent.client, KEY_SPECIAL)) {
                if ( POWERUPS_isOnGround( @ent ) ) {
                    Vec3 newOrigin = ent.origin;
                    newOrigin.z += 0.5f;
                    ent.origin = newOrigin;
                }

                Vec3 fwd, right, up;
                ent.angles.angleVectors(fwd, right, up);
                fwd.z = 0;
                fwd.normalize();

                Vec3 horizontalSpeed = newVelocity;
                horizontalSpeed.z = 0;

                float speed = horizontalSpeed.length();
                float minspeed = 225 + 450 * (this.rands[0] / this.randsMax[0]);
                float maxspeed = 450 + (1.5 * 450 * this.rands[0]);

                float fuelLoss = 10.0f;

                if (speed < minspeed)
                    speed = minspeed;
                else if (speed > maxspeed) {
                    speed = maxspeed;
                    fuelLoss = 5.0f;
                }
                else
                    speed += 5 * minspeed / 450;

                newVelocity.x = fwd.x * speed;
                newVelocity.y = fwd.y * speed;
                newVelocity.z += (this.rands[0] + 10.0f);
                this.fuel -= fuelLoss * (frameTime * 0.001f);
            }
        }
        if ( !POWERUPS_isOnGround( @ent ) ) {
            ent.client.pmoveMaxSpeed = 500;
        } else {
            ent.client.pmoveMaxSpeed = 240;
        }

        if (this.fuel < fuelMax && POWERUPS_isOnGround( @ent ) ) {
            float secondsToRefuel;
            if (!outOfFuel)
                secondsToRefuel = 1.5f;
            else
                secondsToRefuel = 3.0f;

            this.fuel += (fuelMax / secondsToRefuel) * (frameTime * 0.001f);
        }

        if (this.fuel >= fuelMax) {
            this.fuel = fuelMax;
            if (this.outOfFuel)
                this.outOfFuel = false;
        }

        if (this.fuel < this.fuelMax / 10 && !lowOnFuel) {
            this.lowOnFuel = true;
            G_CenterPrintMsg(ent, S_COLOR_RED + "You are low on fuel!");
        }

        if (this.fuel > this.fuelMax / 10 && lowOnFuel)
            this.lowOnFuel = false;

        if (this.fuel < 0) {
            this.fuel = 0;
            this.outOfFuel = true;
            G_CenterPrintMsg(ent, S_COLOR_RED + "You are out of fuel!");
        }

        ent.velocity = newVelocity;
    }
    void clearPowerup(Entity @ent)
    {
        ent.client.pmoveFeatures = this.regular_pmfeats;
        this.fuel = 0;
    };

}

class cPowerUpExtraKnockback : cPowerUp {
    cPowerUpExtraKnockback()
    {
        super(
            POWERUPID_EXTRAKB,
            G_ImageIndex("gfx/hud/icons/vsay/attack"),

            { 1.25f },
            { 2.5f },
            { POWERUP_NUMBERTYPE_MULTIPLIER },

            0.0f, 0.0f,
            "Extra Knockback",
            S_COLOR_RED,
            "You deal %s the knockback to enemies.",
            "You deal %s the knockback to enemies",
            " - %s"
        );
    }


    void dmg(Entity @ent, const String& in args = "") override
    {

        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        float damage = args.getToken(1).toFloat();
        if (@victim.client == null)
            return;
        if (damage > victim.health + victim.client.armor)
            return;
        if (POWERUPS_kb_amount_weapon(ent.weapon) == 0)
            return;
        Vec3 dir;

        Vec3 VictimOrigin = victim.origin;

        dir = victim.origin - ent.origin;
        dir.normalize();

        VictimOrigin.z += 0.25;
        victim.origin = VictimOrigin;
        //TODO: SCALE WITH DAMAGE FOR SPLASH
        victim.sustainDamage(@ent, @ent, dir, 0, POWERUPS_kb_amount_weapon(ent.weapon) * (this.rands[0] - 1.0f), 0, MOD_BARREL);
    }

    // void think(Entity @ent) override {
    //     array<String> projectile_classnames = {"rocket", "grenade", "plasma", "gunblade_blast"};
    //     // ent.client.inventorySetCount(POWERUP_QUAD, 10);
    //     // 1108082688 - 1133903872
    //     // 1108082688 - 1120403456
    //     for ( int i = 0; i < projectile_classnames.length(); i++ )
    //     {
    //         array<Entity @> @ents = G_FindByClassname( projectile_classnames[i] );
    //
    //         for ( int j = 0; j < ents.length(); j++ ) {
    //             if (@ents[j].owner != @ent)
    //                 continue;
    //             if (ents[j].target == "ExtraKB")
    //                 continue;
    //             Vec3 origin = ent.origin;
    //             origin.z += ent.viewHeight;
    //             Entity @newEnt = null;
    //             // origin, angles, speed, radius, damage, knockback, stun, owner
    //             if (ents[j].classname == "rocket")
    //                 @newEnt = @G_FireRocket(ents[j].origin, ents[j].angles, 1150, 125, 80, 100 * this.rands[0], 1250, @ent );
    //             else if (ents[j].classname == "grenade")
    //                 G_Print(ents[j].projectileMinKnockback + "\n");
    //             else if (ents[j].classname == "plasma")
    //                 @newEnt = @G_FirePlasma(ents[j].origin, ents[j].angles, 2500, 45, 15, 20 * this.rands[0], 200, @ent);
    //             else if (ents[j].classname == "gunblade_blast")
    //                 @newEnt = @G_FireBlast(ents[j].origin, ents[j].angles, 3000, 70, 35, 90 * this.rands[0], 0, @ent);
    //
    //
    //             if (@newEnt == null)
    //                 continue;
    //             newEnt.target = "ExtraKB";
    //             ents[j].freeEntity();
    //
    //         }
    //     }
    // };
};

class cPowerUpLaunch : cPowerUp {
    cPowerUpLaunch()
    {
        super(
            POWERUPID_LAUNCH,
            G_ImageIndex("gfx/bomb/carriericon"),

            { 1.25f, 50.0f  },
            { 2.25f, 100.0f },
            { POWERUP_NUMBERTYPE_NUMBER, POWERUP_NUMBERTYPE_INTEGER },

            10.0f, 0.0f,

            "Boom!",
            S_COLOR_ORANGE,
            "You make a powerful explosion with medium range and deal damage to people in close proximity to you.",
            "You make a powerful explosion and deal damage to people in close proximity to you",
            " - Power: %s Damage: %s",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    void select(Entity @ent) override
    {
            POWERUPS_setUpClassaction(@ent, "Boom!");
    }

    void classAction(Entity @ent) override
    {
            if (!checkCooldown(@ent))
                return;
            ent.splashDamage(@ent, 200, this.rands[1], (this.rands[0] * 250), 0, MOD_BARREL);
            ent.explosionEffect(200);
    }
    };

    class cPowerUpInvisibility : cPowerUp {
        cPowerUpInvisibility()
        {
            super(
                POWERUPID_INVISIBILITY,
                G_ImageIndex("gfx/misc/playerspawn"),

                { 0.2f },
                { 1.2f },
                { POWERUP_NUMBERTYPE_NUMBER },
                0.0f, 0.0f,

                "Invisibility",
                S_COLOR_WHITE,
                "You are invisibile while you aren't shooting or in air. You will be visible for %s seconds after you stop shooting or touch the ground, and double that if you are hit.",
                "You are invisibile while you aren't shooting or in air, or being attacked.",
                ""
            );
        }

        void select(Entity @ent) override
        {
            ent.svflags |= SVF_ONLYTEAM;
            // ent.client.pmoveFeatures = POWERUP_INVISIBLE_PMFEATS;

            if (gametype.isInstagib) {
                ent.client.inventoryClear();
                ent.client.inventorySetCount(WEAP_GUNBLADE, 1);
                ent.client.inventorySetCount(AMMO_GUNBLADE, 1);
                ent.client.selectWeapon(-1);
            }

            ent.client.armor = 0;

            this.abilityLength = rint(this.rands[0] * 1000);
            ent.client.pmoveMaxSpeed = 450;
        }

        void think(Entity @ent) override
        {
            bool wantsEnableVisibility = (POWERUPS_isKeyPressed(ent.client, KEY_ATTACK)) || !POWERUPS_isOnGround( @ent ) ;
            if (wantsEnableVisibility) {
                // is visible
                this.ability = false;
                ent.effects &= ~EF_SHELL;
                ent.svflags &= ~SVF_ONLYTEAM;
                this.abilityTimeEnd = levelTime + this.abilityLength;

            } else if (this.abilityTimeEnd < levelTime) {
                // is invisible
                this.ability = true;
                ent.svflags |= SVF_ONLYTEAM;
                ent.effects |= EF_SHELL;
            }

            if (maxClients < 120) {
                String HiddenString = (S_COLOR_CYAN + "Hidden");
                String VisibleString = (S_COLOR_RED + "Visible");
                if (!wantsEnableVisibility && this.abilityTimeEnd >= levelTime) {
                    float secondsUntilEnd = ((float(this.abilityTimeEnd) - float(levelTime)) / 1000);
                    String secondsUntilEndStr = StringUtils::FormatFloat(secondsUntilEnd, "0", 1, 1);
                    VisibleString += " " + secondsUntilEndStr + "s";
                }
                String msg = this.statMessage() + " - " + (this.ability ? HiddenString : VisibleString);
                G_ConfigString(CS_GENERAL + 2 + ent.playerNum, msg);
            }
        }


        void tookdmg(Entity @ent, const String& in args = "") override
        {
            this.ability = false;
            ent.effects &= ~EF_SHELL;
            ent.svflags &= ~SVF_ONLYTEAM;
            this.abilityTimeEnd = levelTime + (this.abilityLength);
        };

        void dmg(Entity @ent, const String& in args = "") override
        {
            // negate splash damage done if in instagib
            if (!gametype.isInstagib)
                return;
            Entity @target = @G_GetEntity(args.getToken(0).toInt());
            float damage = args.getToken(1).toFloat();

            if (damage < 9999.0f)
                target.health += damage;
        };
    };


    class cPowerUpQuad : cPowerUp {
        cPowerUpQuad()
        {
            super(
                POWERUPID_QUAD,
                G_ImageIndex("gfx/hud/icons/powerup/quad"),

                { 3.0f },
                { 7.0f },
                { POWERUP_NUMBERTYPE_NUMBER },
                10.0f, 0.0f,

                "Quad Damage",
                S_COLOR_ORANGE,
                "Your damage is quadrupled for %s seconds",
                "Your damage is quadrupled for %s seconds",
                " - %s seconds",
                POWERUP_HELPMESSAGE_CLASSACTION
            );
        }

        void select(Entity @ent) override
        {
            POWERUPS_setUpClassaction(@ent, "Activate Quad Damage");
        }

        void classAction(Entity @ent) override
        {
            if (!checkCooldown(@ent))
                return;
            this.abilityLength = rint(this.rands[0] * 1000);
            this.abilityTimeEnd = levelTime + this.abilityLength;
            this.cooldownTime = levelTime + this.cooldownLength + abilityLength;

            this.ability = true;

            int soundIndex = G_SoundIndex("sounds/items/quad_pickup");
            G_Sound(ent, CHAN_ITEM, soundIndex, ATTN_NORM);
        }

        void think(Entity @ent) override
        {
            if (!ability) {
                return;
            }
            if (ent.isGhosting())
                return;
            if (this.abilityTimeEnd < levelTime) {
                ability = false;
                return;
            }
            ent.effects |= EF_QUAD;
        }

        void dmg(Entity @ent, const String& in args = "") override
        {
            if (!ability)
                return;
            Entity @victim = @G_GetEntity(args.getToken(0).toInt());
            float damage = args.getToken(1).toFloat();
            if (@victim.client == null)
                return;
            if (damage > victim.health + victim.client.armor)
                return;
            // * 3 because 1x damage was already done
            POWERUPS_dealDamageWithArmor(@victim, damage * 3);
        };

        void clearPowerup(Entity @ent) override
        {
            ability = false;
        };
    };

    // Removed in favour of Immortality
    /*
    class cPowerUpShell : cPowerUp {
        cPowerUpShell() {
            super(
                POWERUPID_SHELL,
                POWERUP_NUMBERTYPE_INTEGER,
                5.0f, 15.0f, false,
                10.0f, 0.0f,
                "WarShell", "Shell",
                S_COLOR_BLUE,
                "You only take in 1/4 of damage for a short amount of time",
                " - %s seconds"
              );
          }

        void select(Entity @ent) override {
            POWERUPS_setUpClassaction( @ent, "Activate WarShell");
        }

        void action(Entity @ent, const String &in args = "" ) override {
            this.cooldownTime = levelTime + this.cooldownLength + (this.rands[0] * 1000);
            int soundIndex = G_SoundIndex( "sounds/items/shell_pickup" );
            G_Sound( ent, CHAN_ITEM, soundIndex, ATTN_NORM );
            ent.client.inventorySetCount(POWERUP_SHELL, floor(this.rands[0]));
        }
    };*/

    class cPowerUpImmortality : cPowerUp {
        cPowerUpImmortality()
        {
            super(
                POWERUPID_IMMORTALITY,
                G_ImageIndex("gfx/hud/icons/powerup/warshell"),

                { 2.0f },
                { 5.0f },
                { POWERUP_NUMBERTYPE_NUMBER },

                15.0f, 0.0f,

                "Immortality",
                S_COLOR_WHITE,
                "You take no damage for %s seconds, including being hit with an Instagun.",
                "You take no damage for %s seconds",
                " - %s seconds",
                POWERUP_HELPMESSAGE_CLASSACTION
            );
        }

        float health;
        float armor;

        void select(Entity @ent) override
        {
            POWERUPS_setUpClassaction(@ent, "Activate Immortality");
        }

        void classAction(Entity @ent) override
        {
            if (!checkCooldown(@ent))
                return;
            this.abilityLength = rint(this.rands[0] * 1000);
            this.abilityTimeEnd = levelTime + this.abilityLength;
            this.cooldownTime = levelTime + this.cooldownLength + abilityLength;

            this.ability = true;

            this.health = ent.health;
            this.armor = ent.client.armor;
            ent.client.armor = 0;
            ent.health = 999;

            int soundIndex = G_SoundIndex("sounds/items/shell_pickup");
            G_Sound(ent, CHAN_ITEM, soundIndex, ATTN_NORM);
        }

        void think(Entity @ent) override
        {
            if (!ability) {
                this.health = ent.health;
                this.armor = ent.client.armor;
                return;
            }
            if (ent.isGhosting())
                return;
            if (this.abilityTimeEnd < levelTime) {
                ent.health = this.health;
                ent.client.armor = this.armor;
                ability = false;
                return;
            }
            ent.effects |= EF_GODMODE;
            ent.health = 999;
        }

        void tookdmg(Entity @ent, const String& in args = "") override
        {
            if (this.ability) {
                float damage = args.getToken(1).toFloat();
                ent.health += damage;
            }
        };

        void clearPowerup(Entity @ent) override
        {
            ent.health = this.health;
            ent.client.armor = this.armor;
            ability = false;
        };
    };

    class cPowerUpPullTowards : cPowerUp {
        cPowerUpPullTowards()
        {
            super(
                POWERUPID_PULL_TOWARDS,
                G_ImageIndex("gfx/hud/icons/vsay/needdefense"),

                { 1.0f },
                { 2.0f },
                { POWERUP_NUMBERTYPE_MULTIPLIER },

                0.0f, 0.0f,


                "Pull Towards",
                S_COLOR_RED,
                "Knockback changes %s as much to pull enemies towards you when you attack them.",
                "Enemies are pulled towards you when you attack them.",
                " - %s"
            );
        }

        void dmg(Entity @ent, const String& in args = "") override
        {

            Entity @victim = @G_GetEntity(args.getToken(0).toInt());
            float damage = args.getToken(1).toFloat();
            if (@victim.client == null)
                return;
            if (damage > victim.health + victim.client.armor)
                return;
            if (POWERUPS_kb_amount_weapon(ent.weapon) == 0)
                return;

            Vec3 dir;

            Vec3 VictimOrigin = victim.origin;

            dir = ent.origin - victim.origin;
            dir.normalize();

            VictimOrigin.z += 0.25;
            victim.origin = VictimOrigin;

            //TODO: SCALE WITH DAMAGE FOR SPLASH
            victim.sustainDamage(@ent, @ent, dir, 0, POWERUPS_kb_amount_weapon(ent.weapon) * (this.rands[0] + 1.0f), 0, MOD_BARREL);
        }
    };

    class cPowerUpInfiniteAmmo : cPowerUp {
        cPowerUpInfiniteAmmo()
        {
            super(
                POWERUPID_INFINITE_AMMO,
                G_ImageIndex("gfx/hud/icons/ammo/pack"),

                { 0.0f },
                { 0.0f },
                { POWERUP_NUMBERTYPE_NONE },

                0.0f, 0.0f,
                "Infinite Ammo",
                S_COLOR_MAGENTA,
                "You have infinite ammo.",
                "You have infinite ammo",
                ""
            );
        }

        void think(Entity @ent) override
        {

            // give the weapons and ammo as defined in cvars
            String token, weakammotoken, ammotoken;
            String itemList = g_noclass_inventory.string;
            String ammoCounts = g_class_strong_ammo.string;
            for (int i = 0;; i++) {
                token = itemList.getToken(i);
                if (token.len() == 0)
                    break; // done

                Item @item = @G_GetItemByName(token);
                if (@item == null)
                    continue;

                // if it's ammo, set the ammo count as defined in the cvar
                if ((item.type & IT_AMMO) != 0) {
                    token = ammoCounts.getToken(item.tag - AMMO_GUNBLADE);

                    if (token.len() > 0) {
                        ent.client.inventorySetCount(item.tag, token.toInt());
                    }
                }
            }
        }
    };

    class cPowerUpProjectileSpeed : cPowerUp {
        cPowerUpProjectileSpeed()
        {
            super(
                POWERUPID_PROJECTILESPEED,
                G_ImageIndex("gfx/hud/icons/vsay/onoffense"),

                { 1.5f },
                { 3.0f },
                { POWERUP_NUMBERTYPE_MULTIPLIER },

                0.0f,
                0.0f,

                "Projectile Speed",
                S_COLOR_GREEN,
                "Your projectiles (rocket, grenade, plasma, gunblade blast) are %s as fast.",
                "Your projectiles are %s as fast.",
                " - %s"
            );
        }


        void think(Entity @ent) override
        {
            array<String> projectile_classnames = { "rocket", "grenade", "plasma", "gunblade_blast" };
            for (uint i = 0; i < projectile_classnames.length(); i++) {
                array<Entity @> @ents = G_FindByClassname(projectile_classnames[i]);

                for (uint j = 0; j < ents.length(); j++) {
                    if (@ents[j].owner != @ent)
                        continue;
                    if (ents[j].target == "fasterProjectile")
                        continue;
                    ents[j].velocity *= this.rands[0];
                    ents[j].target = "fasterProjectile"; // tag them to not use them again
                }
            }
        };
    };

    class cPowerUpFreezeEnemies : cPowerUp {
        cPowerUpFreezeEnemies()
        {
            super(
                POWERUPID_FREEZE_ENEMIES,
                0,                                          // TODO: NO IMAGE

                { 0.2f },
                { 0.5f },
                { POWERUP_NUMBERTYPE_PERCENT },
                0.0f, 0.0f,
                "Freeze Enemies",
                S_COLOR_BLUE,
                "You have a %s chance to freeze an enemy for an amount of time proportionate to the damage when you attack them.",
                "You have a %s chance to freeze an enemy when you hit them",
                " - %s"
            );
        }
        uint[] regular_pmfeats(maxClients);
        bool[] frozen(maxClients);
        uint[] frozenUntil(maxClients);
        Vec3[] frozenOrigin(maxClients);
        Vec3[] frozenVelocity(maxClients);

        void select(Entity @ent) override
        {
            for (int i = 0; i < maxClients; i++) {
                frozen[i] = false;
                frozenUntil[i] = 0;
                frozenOrigin[i] = Vec3(0, 0, 0);
                frozenVelocity[i] = Vec3(0, 0, 0);
                regular_pmfeats[i] = G_GetClient(i).pmoveFeatures;
            }
        };

        void dmg(Entity @ent, const String& in args = "") override
        {
            Entity @victim = @G_GetEntity(args.getToken(0).toInt());
            float damage = args.getToken(1).toFloat();

            if (@victim.client == null)
                return;
            if (victim.isGhosting())
                return;

            if (this.rands[0] > random()) {
                float freezeTime = damage / 30;
                String freezeTimeStr = StringUtils::FormatFloat(freezeTime, "0", 1, 1);

                if (frozen[victim.playerNum]) {

                    freezeTime /= 2;
                    freezeTimeStr = StringUtils::FormatFloat(freezeTime, "0", 1, 1);

                    frozenUntil[victim.playerNum] += rint(ceil(1000 * freezeTime));
                    return;
                }

                G_CenterPrintMsg(ent, "You froze " + victim.client.name + S_COLOR_WHITE + "!");
                G_CenterPrintMsg(victim, "You were frozen by " + ent.client.name + "!");

                // G_PrintMsg(ent, "You froze " + victim.client.name + S_COLOR_WHITE + "!\n");
                // G_PrintMsg(victim, "You were frozen by " + ent.client.name + "!\n");

                frozen[victim.playerNum] = true;
                frozenUntil[victim.playerNum] = levelTime + rint(ceil(1000 * freezeTime));
                frozenVelocity[victim.playerNum] = victim.velocity;
                frozenOrigin[victim.playerNum] = victim.origin;
                regular_pmfeats[victim.playerNum] = victim.client.pmoveFeatures;
            }
        }

        void clearPowerup(Entity @ent) override
        {
            for (int i = 0; i < maxClients; i++) {
                Entity @victim = @G_GetClient(i).getEnt();
                if (frozen[victim.playerNum]) {
                    victim.velocity = frozenVelocity[victim.playerNum];
                    victim.client.pmoveFeatures = regular_pmfeats[victim.playerNum];
                    frozen[victim.playerNum] = false;
                    G_CenterPrintMsg(victim, ent.client.name + S_COLOR_WHITE + " died, you have been unfrozen!");
                    G_PrintMsg(victim, ent.client.name + S_COLOR_WHITE + " died, you have been unfrozen!\n");
                };
            };
        };
        void think(Entity @ent) override
        {

            for (int i = 0; i < maxClients; i++) {
                Entity @victim = @G_GetClient(i).getEnt();
                if (frozen[victim.playerNum]) {
                    // G_Print(( frozenAt[victim.playerNum] + this.abilityLength) + "FROZEN");
                    victim.origin = frozenOrigin[victim.playerNum];
                    victim.velocity = Vec3(0, 0, 0);
                    victim.client.pmoveFeatures &= ~POWERUP_FROZEN_PMFEATS_NEGATE;

                    float frozenTime = float(frozenUntil[victim.playerNum] - float(levelTime)) / 1000.0f;
                    G_CenterPrintMsg(victim, "Frozen for " + POWERUPS_formatFloat(POWERUP_NUMBERTYPE_NUMBER, frozenTime) + " seconds!");

                    if (frozenUntil[victim.playerNum] < levelTime || victim.isGhosting() ) {
                        victim.velocity = frozenVelocity[victim.playerNum];
                        victim.client.pmoveFeatures = regular_pmfeats[victim.playerNum];
                        frozen[victim.playerNum] = false;
                        G_CenterPrintMsg(victim, "");
                    }
                };
            };
        };
    }

    class cPowerUpAimbot : cPowerUp {
        cPowerUpAimbot()
        {
            super(
                POWERUPID_AIMBOT,
                G_ImageIndex("gfx/hud/icons/vsay/areasecured"),

                { 0.20f },
                { 0.35f },
                { POWERUP_NUMBERTYPE_NUMBER },

                0.0f, 0.0f,

                "Weak Aimbot",
                S_COLOR_YELLOW,
                "Target an enemy by damaging them, and hold the special button to aim at a targeted enemy, but only doing 2/3 damage and not being able to use your special key movement.",
                "Hold the special button to aim at a targeted enemy, at the cost of you doing 2/3 damage",
                "",
                POWERUP_HELPMESSAGE_AIMBOT
            );
        }

        Entity @target = null;

        void select(Entity @ent) override
        {
            ent.client.pmoveFeatures &= ~POWERUP_AIMBOT_PMFEATS_NEGATE;
            ent.client.armor = 75;
        };

        void dmg(Entity @ent, const String& in args = "") override
        {
            Entity @victim = @G_GetEntity(args.getToken(0).toInt());
            float damage = args.getToken(1).toFloat();

            if (@victim.client == null)
                return;
            if (victim.isGhosting())
                return;
            if (@victim == @ent)
                return;

            cPowerUp @pwr = @powerUp[victim.playerNum];
            if ( !( pwr.powerupID == POWERUPID_IMMORTALITY && pwr.ability ) )
                victim.health += (damage / 3.0f);

            if (@victim == @target)
                return;

            @target = @victim;
            G_CenterPrintMsg(ent, "Set new target to " + target.client.name);
        }

        void think(Entity @ent) override
        {
            // x = -90 (up) +90 (down)
            // y = -180 to 180
            if (maxClients < 120) {
                G_ConfigString(CS_GENERAL + 2 + ent.playerNum, this.statMessage() + " - Target: " + (@target != null ? target.client.name : "Nobody"));
            }

            if (@target == null)
                return;
            if (target.isGhosting()) {
                @target = null;
                return;
            }

            if (@powerUp[target.playerNum] != null && powerUp[target.playerNum].powerupID == POWERUPID_INVISIBILITY && powerUp[target.playerNum].ability)
                return;

            if (POWERUPS_isKeyPressed(ent.client, KEY_SPECIAL) || (ent.client.isBot() && POWERUPS_isKeyPressed(ent.client, KEY_ATTACK))) {

                Vec3 mins, maxs;
                target.getSize( mins, maxs );
                Vec3 targetPoint = target.origin;
                targetPoint.z += target.viewHeight;

                Vec3 currentOrigin = ent.origin;
                currentOrigin.z += ent.viewHeight;

                Vec3 dir = targetPoint - currentOrigin;
                dir.normalize();

                Vec3 targetAngles = dir.toAngles();
                Vec3 currentAngles = ent.angles;

                Trace trace;
                if (trace.doTrace(currentOrigin, Vec3(0, 0, 0), Vec3(0, 0, 0), targetPoint, ent.entNum, MASK_SOLID))
                    return;

                // fix angle wrapping
                float deltaX = targetAngles.x - currentAngles.x;
                float deltaY = targetAngles.y - currentAngles.y;

                if (deltaX > 180)
                    deltaX -= 360;
                if (deltaX < -180)
                    deltaX += 360;
                if (deltaY > 180)
                    deltaY -= 360;
                if (deltaY < -180)
                    deltaY += 360;

                currentAngles.x += deltaX * 0.5 * this.rands[0];
                currentAngles.y += deltaY * 0.5 * this.rands[0];

                ent.angles = currentAngles;
            }
        };
    }

    // scrapped because cant SVF_OWNERANDCHASERS, because ent.frame and ent.ownerNum are the same for whatever reason ???
    /*
    class cPowerUpWallhack : cPowerUp {
        cPowerUpWallhack() {
            super(
                POWERUPID_WALLHACK,
                0,

                { 0.0f },
                { 0.0f },
                { POWERUP_NUMBERTYPE_NONE },

                0.0f, 0.0f,

                "Wallhack",
                S_COLOR_YELLOW,
                "You can see enemies through walls.",
                "You can see enemies through walls",
                ""
            );
        }

        int[] broadcasterEntNum(maxClients);


        void select(Entity @ent) override {
            ent.client.armor = 25;
            for ( int i = 0; i < maxClients; i++ )
            {
                Entity @broadcasterEnt;
                Entity @target = @G_GetClient( i ).getEnt();
                broadcasterEntNum[i] = -1;

                if (@target.client == null)
                    continue;
                if (ent.team == target.team)
                    continue;
                if (target.isGhosting())
                    continue;

                @broadcasterEnt = @G_SpawnEntity( "capture_indicator_sprite" );
                @broadcasterEnt.owner = @ent;
                broadcasterEnt.ownerNum = ent.entNum;
                // broadcasterEnt.frame = 64;
                broadcasterEnt.type = ET_RADAR;
                broadcasterEnt.solid = SOLID_NOT;
                broadcasterEnt.modelindex = G_ImageIndex( "gfx/indicators/radar" );
                broadcasterEnt.svflags = ( SVF_BROADCAST | SVF_ONLYOWNER );
                broadcasterEnt.team = ent.team;

                broadcasterEntNum[i] = broadcasterEnt.entNum;
            }
        };

        void think(Entity @ent) override {
            for ( int i = 0; i < maxClients; i++ )
            {
                Entity @broadcasterEnt;
                Entity @target = @G_GetClient( i ).getEnt();
                if (@target.client == null)
                    continue;
                if (ent.team == target.team)
                    continue;
                if (broadcasterEntNum[i] == -1)
                    continue;

                if (target.isGhosting()) {
                    @broadcasterEnt = @G_GetEntity( broadcasterEntNum[i] );
                    broadcasterEntNum[i] = -1;
                    broadcasterEnt.freeEntity();
                    continue;
                }

                @broadcasterEnt = @G_GetEntity( broadcasterEntNum[i] );
                broadcasterEnt.origin = target.origin;
                broadcasterEnt.velocity = target.velocity;


            }
        };

        void clearPowerup(Entity @ent) override {
            array<Entity @> @ents = G_FindByClassname( "capture_indicator_sprite" );

            for ( uint i = 0; i < ents.length(); i++ ) {
                if (@ents[i].owner != @ent)
                    continue;
                ents[i].freeEntity();

            }

        };
    }
    */


class cPowerUpClone : cPowerUp {
    cPowerUpClone()
    {
        super(
            POWERUPID_CLONE,
            0,                                              // TODO: NO IMAGE

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            5.0f, 0.0f,

            "Clone",
            S_COLOR_YELLOW,
            "Place a clone of yourself which dies to one hit",
            "Place a clone of yourself which dies to one hit",
            "",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    Entity @clone;

    void select(Entity @ent) override
    {
        POWERUPS_setUpClassaction(@ent, "Spawn clone");
    }

    void clearPowerup(Entity @ent) override {
        array<Entity @> @ents = G_FindByClassname( "clone" );

        for ( uint i = 0; i < ents.length(); i++ ) {
            if (@ents[i].owner != @ent)
                continue;
            ents[i].freeEntity();
        }
    }

    void classAction(Entity @ent) override
    {
        if (ent.health <= 0)
            return;
        if (!checkCooldown(@ent))
            return;

        Vec3 mins, maxs;
        ent.getSize( mins, maxs );



        if (@clone != null && clone.classname == "clone" && @clone.owner == @ent )
            clone.freeEntity();

        @clone = @G_SpawnEntity("clone");

        Vec3 fwd, right, up;
        Vec3 entVel = ent.velocity;
        if (entVel.z < 0)
            entVel.z = 0;

        ent.angles.angleVectors(fwd, right, up);
        fwd.normalize();
        fwd *= entVel.length() + 100;
        fwd.z += 200;

        @clone.owner = @ent;

        clone.type = ET_PLAYER;
        clone.moveType = MOVETYPE_TOSS;

        clone.origin = ent.origin;
        clone.angles = ent.angles;
        clone.mass = ent.mass;
        clone.velocity = fwd;
        clone.setSize(mins, maxs);
        clone.team = ent.team;
        clone.solid = SOLID_YES;

        clone.setupModel("models/players/" + ent.client.getUserInfoKey( "model" ), "fullbright");
        // clone.skinNum = ent.skinNum;

        clone.svflags = ent.svflags & ~SVF_NOCLIENT | SVF_FAKECLIENT | SVF_BROADCAST;
        clone.frame = ent.frame;
        clone.clipMask = MASK_PLAYERSOLID;

        clone.weapon = ent.weapon;

        clone.takeDamage = DAMAGE_YES;
        clone.health = 1;

        clone.timeStamp = levelTime;

        @clone.think = POWERUPS_clone_think;
        @clone.die = POWERUPS_clone_die;
        clone.nextThink = levelTime;

        clone.linkEntity();

    }


}
void POWERUPS_clone_think(Entity @ent) {

    Vec3 mins, maxs;
    ent.getSize( mins, maxs );

    ent.nextThink = levelTime + 100;

    if (ent.timeStamp + 5000 < levelTime) {                           // 5 sec
        ent.freeEntity();
        return;
    }

    Trace trace;
    bool inWall = trace.doTrace(ent.origin, mins, maxs, ent.origin, ent.entNum, MASK_PLAYERSOLID);
    if (inWall) {
        if (@ent.owner.client != null) {
            cPowerUp @pwr = powerUp[ent.owner.playerNum];
            pwr.cooldownTime = levelTime;
        }
        ent.freeEntity();
      }
}

void POWERUPS_clone_die(Entity @ent, Entity @inflicter, Entity @attacker) {
    ent.freeEntity();
};

class cPowerUpTeleporter : cPowerUp {
    cPowerUpTeleporter()
    {
        super(
            POWERUPID_TELEPORTER,
            0,                                              // TODO: NO IMAGE

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            5.0f, 0.0f,

            "Teleporter",
            S_COLOR_YELLOW,
            "Place a one-time use teleporter at which you can teleport to anytime",
            "Place a one-time use teleporter at which you can teleport to anytime",
            "",
            POWERUP_HELPMESSAGE_CLASSACTION
          );
    }

    Entity @teleporter = null;
    Entity @teleporterBody = null;

    void select(Entity @ent) override
    {
        POWERUPS_setUpClassaction(@ent, "Place teleporter");
    }

    void clearPowerup(Entity @ent) override {
        array<Entity @> @ents = G_FindByClassname( "teleporter" );

        for ( uint i = 0; i < ents.length(); i++ ) {
            if (@ents[i].owner != @ent)
                continue;
            array<Entity @> @bodyEnts = G_FindByClassname( "teleporter_body" );

            for ( uint j = 0; j < ents.length(); j++ ) {
                if (@bodyEnts[j].owner != @ents[i])
                    continue;
                bodyEnts[j].freeEntity();
            }
            ents[i].freeEntity();
        }


      }

    void classAction(Entity @ent) override
    {

        if (ent.health <= 0)
        return;
        if (!checkCooldown(@ent))
        return;

        if (@teleporter != null && @teleporter.owner == @ent ) {
            ent.teleportEffect( true );


            ent.origin = teleporter.origin;
            ent.angles = teleporter.angles;

            Vec3 vel = ent.velocity;

            Vec3 fwd, right, up;
            ent.angles.angleVectors(fwd, right, up);
            fwd.z = 0;
            fwd.normalize();

            Vec3 horizontalSpeed = vel;
            horizontalSpeed.z = 0;
            float hspeed = horizontalSpeed.length();

            vel.x = fwd.x * hspeed;
            vel.y = fwd.y * hspeed;

            ent.velocity = vel;

            Vec3 mins, maxs;
            ent.getSize(mins, maxs);

            Trace trace;
            trace.doTrace( ent.origin, mins, maxs, ent.origin, ent.entNum, MASK_PLAYERSOLID );
            if ( trace.entNum > 0 ) {
                Entity @telefragTarget = @G_GetEntity( trace.entNum );
                if (@telefragTarget.client != null) {
                    // hacky way to allow for teamfrags
                    int team = ent.team;
                    ent.team = TEAM_PLAYERS;
                    telefragTarget.sustainDamage(@teleporter, @ent, Vec3(0, 0, 0), 100000, 0, 0, MOD_TELEFRAG);
                    ent.team = team;
                }
            }

            POWERUPS_setUpClassaction(@ent, "Place teleporter");

            if (@teleporterBody != null && @teleporterBody.owner == @teleporter ) {
                teleporterBody.freeEntity();
            }
            teleporter.freeEntity();
            ent.teleportEffect( false );
            return;
        }

        // on ground or jumping
        if (!POWERUPS_isOnGround(@ent) || POWERUPS_isKeyPressed(@ent.client, KEY_JUMP) ) {
            this.cooldownTime = 0;
            G_PrintMsg(ent, this.color + this.name + S_COLOR_WHITE + " can only be placed when on the ground.\n");
            return;
        }

        @teleporter = @G_SpawnEntity("teleporter");

        @teleporter.owner = @ent;

        teleporter.type = ET_GENERIC;

        teleporter.origin = ent.origin;
        teleporter.angles = ent.angles;

        teleporter.team = ent.team;


        teleporter.svflags &= ~SVF_NOCLIENT;
        teleporter.svflags |= SVF_BROADCAST;
        teleporter.clipMask = MASK_PLAYERSOLID;

        @teleporterBody = @G_SpawnEntity("teleporter_body");
        @teleporterBody.owner = @teleporter;


        teleporterBody.type = ET_GENERIC;

        teleporterBody.origin = ent.origin;

        teleporterBody.moveType = MOVETYPE_TOSS;

        teleporterBody.svflags &= ~SVF_NOCLIENT;
        teleporterBody.svflags |= SVF_BROADCAST;
        teleporterBody.clipMask = MASK_SOLID;

        Vec3 mins( -16.0, -16.0, -16.0 ), maxs( 16.0, 16.0, 40.0 );
        teleporterBody.setSize(mins, maxs);

        teleporterBody.setupModel("models/objects/flag/flag_base.md3");

        teleporterBody.team = ent.team;

        // TODO: this doesnt work
        teleporterBody.takeDamage = DAMAGE_YES;
        teleporterBody.health = 50;

        @teleporterBody.die = @POWERUPS_teleporter_die;

        teleporter.linkEntity();
        POWERUPS_setUpClassaction(@ent, "Use teleporter");

    }


}

void POWERUPS_teleporter_die(Entity @ent, Entity @inflicter, Entity @attacker) {
    Entity @teleporterBody = @ent;
    Entity @teleporter = @teleporterBody.owner;
    Entity @player = @teleporter.owner;

    if (@player != null && @player.client != null) {
        String msg;
        if (@attacker.client != null)
            msg = "Your teleporter was destroyed by " + attacker.client.name + S_COLOR_WHITE + "!";
        else
            msg = "Your teleporter was destroyed!";

        G_CenterPrintMsg(player, S_COLOR_RED + msg);
    }
    teleporterBody.freeEntity();
    teleporter.freeEntity();
};

    void POWERUPS_clearPowerupState(Entity @ent)
    {
        cPowerUp @pwr = @powerUp[ent.playerNum];
        pwr.clearPowerup(@ent);

        GENERIC_ClearQuickMenu(@ent.client);

        // powerup cooldown
        ent.client.setHUDStat(STAT_PROGRESS_SELF, 0);
        // powerup message
        ent.client.setHUDStat(STAT_MESSAGE_SELF, 0);

        // TODO: replace the placeholder images with some actual images
        // ent.client.setHUDStat(STAT_IMAGE_SELF, 0 );

        ent.client.setHelpMessage( 0 );

        POWERUPS_applyPowerupByID(@ent, 0);
        ent.svflags &= ~SVF_ONLYTEAM;
        ent.client.pmoveDashSpeed = -1;
        ent.client.pmoveMaxSpeed = -1;
        ent.client.pmoveJumpSpeed = -1;
        ent.maxHealth = 100;
    };

    // utils
    void POWERUPS_setUpClassaction(Entity @ent, String infotext, String command = "classaction1")
    {
        GENERIC_SetQuickMenu(@ent.client, "\"" + infotext + "\" \"" + command + "\"");
    };

    String POWERUPS_getRandomPowerupName()
    {
        uint id = chooseablePowerupList[POWERUPS_randomInteger(0, chooseablePowerupList.length() - 1)];
        cPowerUp @pwr = @POWERUPS_getPowerUpByID(id);
        return pwr.color + pwr.name;
    }

    void POWERUPS_applyRandomPowerup(Entity @ent)
    {

        uint id = chooseablePowerupList[POWERUPS_randomInteger(0, chooseablePowerupList.length() - 1)];

        // id = POWERUPID_QUAD;
        // if (ent.playerNum == 0) // debug powerup
            // id = POWERUPID_QUAD;

        if (ent.isGhosting())
            id = POWERUPID_NONE;
        POWERUPS_clearPowerupState(@ent);
        POWERUPS_applyPowerupByID(@ent, id);
    }
    void POWERUPS_applyPowerupByID(Entity @ent, uint id)
    {
        @powerUp[ent.playerNum] = @POWERUPS_getPowerUpByID(id);

        if (@powerUp[ent.playerNum] != null) {
            powerUp[ent.playerNum].init(ent);
            powerUp[ent.playerNum].select(ent);
        }
    };

    void POWERUPS_initialise()
    {
        G_ConfigString(CS_HELPMESSAGES + POWERUP_HELPMESSAGE_CLASSACTION,
        "Use with " + POWERUPS_helpmsg_bind("{Bclassaction1}") + " or open the quickmenu by holding " + POWERUPS_helpmsg_bind("{B+quickmenu}") + " and press " + POWERUPS_helpmsg_bind("1") + " to use."
        );

        G_ConfigString(CS_HELPMESSAGES + POWERUP_HELPMESSAGE_JETPACK,
        "Hold " + POWERUPS_helpmsg_bind("{B+moveup}") + " to fly, " + POWERUPS_helpmsg_bind("{B+movedown}") + " to descend and " + POWERUPS_helpmsg_bind("{B+special}") + " to boost."
        );
        G_ConfigString(CS_HELPMESSAGES + POWERUP_HELPMESSAGE_AIMBOT,
        "Select someone to target by attacking them. Hold " + POWERUPS_helpmsg_bind("{B+special}") + " to look at your target."
        );

        if ( chooseablePowerupList.empty() )                // was not already created by the gametype ascript
            if ( !gametype.isInstagib )
                chooseablePowerupList = {
                    POWERUPID_SWAP,
                    POWERUPID_INSTA,
                    POWERUPID_VAMPIRE,
                    POWERUPID_MAXSPEED,
                    POWERUPID_DASH,
                    POWERUPID_JUMP,
                    POWERUPID_EXTRADMG,
                    POWERUPID_JETPACK,
                    POWERUPID_EXTRAKB,
                    POWERUPID_LAUNCH,
                    POWERUPID_INVISIBILITY,
                    POWERUPID_QUAD,
                    POWERUPID_IMMORTALITY,
                    POWERUPID_PULL_TOWARDS,
                    POWERUPID_INFINITE_AMMO,
                    POWERUPID_PROJECTILESPEED,
                    POWERUPID_FREEZE_ENEMIES,
                    POWERUPID_AIMBOT,
                    POWERUPID_CLONE,
                    POWERUPID_TELEPORTER
                };
            else
                chooseablePowerupList = {
                    POWERUPID_SWAP,
                    POWERUPID_MAXSPEED,
                    POWERUPID_DASH,
                    POWERUPID_JUMP,
                    POWERUPID_JETPACK,
                    POWERUPID_LAUNCH,
                    POWERUPID_INVISIBILITY,
                    POWERUPID_IMMORTALITY,
                    POWERUPID_CLONE,
                    POWERUPID_TELEPORTER
                };
    }

    void POWERUPS_Think()
    {

        for (int i = 0; i < maxClients; i++) {
            Entity @ent = @G_GetClient(i).getEnt();

            if (match.getState() >= MATCH_STATE_POSTMATCH || match.getState() < MATCH_STATE_PLAYTIME) {
                // powerup cooldown
                ent.client.setHUDStat(STAT_PROGRESS_SELF, 0);
                // powerup message
                ent.client.setHUDStat(STAT_MESSAGE_SELF, 0);

                // ent.client.setHUDStat(STAT_IMAGE_SELF, 0);

            } else {
                cPowerUp @pwr = @powerUp[ent.playerNum];

                if (@pwr == null) {
                    POWERUPS_applyPowerupByID(ent, POWERUPID_NONE);
                    continue;
                }

                if (ent.isGhosting()) {
                    if (!ent.client.chaseActive) {
                        // powerup cooldown
                        ent.client.setHUDStat(STAT_PROGRESS_SELF, 0);
                        // powerup message
                        ent.client.setHUDStat(STAT_MESSAGE_SELF, 0);

                        // ent.client.setHUDStat(STAT_IMAGE_SELF, 0 );
                    }

                    if (pwr.powerupID != POWERUPID_NONE)
                        POWERUPS_clearPowerupState(@ent);
                    continue;
                }

                pwr.think(ent);

                ent.client.setHUDStat(STAT_PROGRESS_SELF, rint(pwr.getStatFloat() * 100.0f));
            }
        }
    };
