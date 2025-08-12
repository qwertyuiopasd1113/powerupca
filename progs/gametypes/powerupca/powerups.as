// TODO
// images for powerups
// balancing (make more powerful, dont want QC situation where theyre all meh)
// it's for fun, dont make it too competitive :)

// more powerups (maybe flashbang, fast attacks)

array<int> chooseablePowerupList;

int[] POWERUPS_nextRoundID(maxClients);
bool[] POWERUPS_seenWelcomeMessage( maxClients );
array<cPowerUp @> powerUp(maxClients);
bool[] actionPressed(maxClients);

const uint EF_RACEGHOST = 1<<17;

const int CS_HELPMESSAGES = CS_GENERAL + 128 + 128;

enum PowerUpHelpMessages {
    POWERUP_HELPMESSAGE_WELCOME = 1,
    POWERUP_HELPMESSAGE_CLASSACTION,
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
    POWERUP_NUMBERTYPE_PERCENT,
    POWERUP_NUMBERTYPE_NUMBER,
    POWERUP_NUMBERTYPE_INTEGER
};

enum PowerUpID {
    POWERUPID_NONE = 0,
    POWERUPID_GODMODE,
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
    POWERUPID_WALLHACK,
    POWERUPID_CLONE,
    POWERUPID_TELEPORTER,
    POWERUPID_SELFKB,
    POWERUPID_GRAPPLE,
    POWERUPID_MULTIJUMP,
    POWERUPID_HOMINGPROJS,
    POWERUPID_EXTRAHP,
    POWERUPID_FEAR,
    POWERUPID_REFLECTION,
    POWERUPID_HITSLOWDOWN,
    POWERUPID_FLAMETHROWER,
    POWERUPID_ANTIKB,

    maxPowerupID
}

cPowerUp POWERUPS_getPowerUpByID(uint id)
{
    switch (id) {
        case POWERUPID_GODMODE:          return cPowerUpGodMode();
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
        case POWERUPID_WALLHACK:         return cPowerUpWallhack();
        case POWERUPID_CLONE:            return cPowerUpClone();
        case POWERUPID_TELEPORTER:       return cPowerUpTeleporter();
        case POWERUPID_SELFKB:           return cPowerUpSelfKnockback();
        case POWERUPID_GRAPPLE:          return cPowerUpGrapple();
        case POWERUPID_MULTIJUMP:        return cPowerUpMultiJump();
        case POWERUPID_HOMINGPROJS:      return cPowerUpHomingProjectiles();
        case POWERUPID_EXTRAHP:          return cPowerUpExtraHealth();
        case POWERUPID_FEAR:             return cPowerUpFear();
        case POWERUPID_REFLECTION:       return cPowerUpReflection();
        case POWERUPID_HITSLOWDOWN:      return cPowerUpHitSlowdown();
        case POWERUPID_FLAMETHROWER:     return cPowerUpFlameThrower();
        case POWERUPID_ANTIKB:           return cPowerUpAntiKB();

        default:                         return cPowerUpNone();
    }

}
// const uint POWERUP_INVISIBLE_PMFEATS = PMFEAT_DEFAULT & ~(
//     PMFEAT_CROUCH
// );

const uint POWERUP_JETPACK_PMFEATS_NEGATE = (PMFEAT_CROUCH | PMFEAT_JUMP | PMFEAT_DASH | PMFEAT_WALLJUMP);
const uint POWERUP_FROZEN_PMFEATS_NEGATE = (PMFEAT_CROUCH | PMFEAT_JUMP | PMFEAT_DASH | PMFEAT_WALLJUMP);
// const uint POWERUP_AIMBOT_PMFEATS_NEGATE = (PMFEAT_CROUCH);
const uint POWERUP_FEARED_PMFEATS_NEGATE = ( PMFEAT_GUNBLADEAUTOATTACK | PMFEAT_WEAPONSWITCH );
const uint POWERUP_REFLECTION_PMFEATS_NEGATE = ( PMFEAT_CROUCH );

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
        this.rands = setUpRands(randsMin, randsMax, randNumTypes);


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

    void showPowerupInfo(Entity @ent)
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

    array<float> setUpRands(array<float> minRands, array<float> maxRands, array<uint> numTypes)
    {
        if (minRands.length() != maxRands.length()) {
            G_Print(S_COLOR_YELLOW + "WARNING: minRands length != maxRands length\n");
            return { 0.0f };
        }

        array<float> randomNumbers(minRands.length());

        for (uint i = 0; i < minRands.length(); i++) {
            if ( numTypes[i] == POWERUP_NUMBERTYPE_INTEGER )
            {
                randomNumbers[i] = floor(brandom(minRands[i] + 0.5f, maxRands[i] + 0.5f));
            }
            else
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

    void onActionPress(Entity @ent) { }
    void onActionRelease(Entity @ent) { }

    void sendPowerupMessage(Entity @msgFrom, uint powerupID, String msg = "" ) { }

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
class cPowerUpGodMode : cPowerUp {
    cPowerUpGodMode()
    {
        super(
            POWERUPID_GODMODE,
            0,


            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            0.0f, 0.0f,

            "Godmode",
            S_COLOR_WHITE,
            "You are invincible.",
            "You are invincible",
            ""
        );
    }

    void think(Entity @ent)
    {
        ent.health = 999;
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

            8.0f, 0.0f,

            "Position Swap",
            S_COLOR_ORANGE,
            "Swap positions of yourself and the enemy furthest away from you.",
            "Swap positions of yourself and the enemy furthest away from you",
            "",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    void onActionPress(Entity @ent)
    {

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

        // send a message to frozen to change origin
        for (int j = 0; j < maxClients; j++) {
            cPowerUp @pwr = @powerUp[j];
            if ( pwr.powerupID == POWERUPID_FREEZE_ENEMIES )
            {
                pwr.sendPowerupMessage( @ent, this.powerupID );
                pwr.sendPowerupMessage( @targetEnt, this.powerupID );
            }
        }

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
            "You frag people in one hit, you have no armor, and you gain one more bullet if you frag with the Gunblade.",
            "You frag people in one hit, but you have no armor and you have a long reload time if you miss.",
            ""
        );
    }


    int instaAmmo = 0;
    uint timeShot = 0;
    bool hit = false;

    void think(Entity @ent)
    {
        //if it has went down by 1
        if ( instaAmmo - 1 == ent.client.inventoryCount( AMMO_INSTAS ) && timeShot == 0 )
        {
            // G_Print("weapon " + i + " shot\n");
            instaAmmo = ent.client.inventoryCount( AMMO_INSTAS );
            timeShot = levelTime;
            ent.client.inventorySetCount(AMMO_INSTAS, 0);
        }
        if ( (levelTime - timeShot >= 2000 && timeShot != 0) || hit )
        {
            timeShot = 0;
            ent.client.inventorySetCount(AMMO_INSTAS, instaAmmo);
            hit = false;
        }
        if ( instaAmmo == 0 )
        {
            ent.client.selectWeapon(WEAP_GUNBLADE);
        }
    }

    float getStatFloat()
    {
        return timeShot == 0 ? timeShot : ( float(levelTime - timeShot) / 2000 );
    };

    void select(Entity @ent)
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

        if (enemiesAlive + 1 > 5)
            ent.client.inventorySetCount(AMMO_INSTAS, 5 );
        else
            ent.client.inventorySetCount(AMMO_INSTAS, enemiesAlive + 1 );

        ent.client.armor = 0;
        ent.client.selectWeapon(-1);


        instaAmmo = ent.client.inventoryCount( AMMO_INSTAS );
    }

    void dmg(Entity @ent, const String& in args = "")
    {
        hit = true;

        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        // float damage = args.getToken( 1 ).toFloat();
        if (@victim.client == null)
            return;
        cPowerUp @pwr = @powerUp[victim.playerNum];
        if ( pwr.powerupID == POWERUPID_REFLECTION && pwr.ability )
        {
            ent.sustainDamage(@ent, @victim, Vec3(0, 0, 0), 200, 0, 0, MOD_HIT);
        }
        if ( !( pwr.powerupID == POWERUPID_IMMORTALITY && pwr.ability ) )
        {
            victim.health -= 9999;
            if (ent.client.weapon == WEAP_GUNBLADE)
            {
                instaAmmo++;
                ent.client.inventorySetCount(AMMO_INSTAS, instaAmmo);
                timeShot = levelTime - 2000;
                // the one we just gave
                if ( ent.client.inventoryCount(AMMO_INSTAS) == 1 )
                {
                    ent.client.selectWeapon(WEAP_INSTAGUN);
                }
            }
        }
    }

    void onActionPress(Entity @ent)
    {
        if (ent.client.isBot())
            return;

        int weaponToSwitch = (ent.weapon == WEAP_INSTAGUN ? WEAP_GUNBLADE : WEAP_INSTAGUN);
        if ( ent.client.canSelectWeapon(weaponToSwitch) )
            ent.client.selectWeapon(weaponToSwitch);
    }

}

class cPowerUpVampire : cPowerUp {
    cPowerUpVampire()
    {
        super(
            POWERUPID_VAMPIRE,
            G_ImageIndex("gfx/hud/icons/classactions/medic1"),


            { 0.35f },
            { 0.65f },
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

    void select(Entity @ent)
    {
        ent.health = 250;
        ent.maxHealth = 250;
        ent.client.armor = 0;
    };


    void dmg(Entity @ent, const String& in args = "")
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
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Acceleration",
            S_COLOR_CYAN,
            "Your max speed is %sx the normal amount, and you gain speed at a much faster rate.",
            "You accelerate %sx faster",
            " - %sx"
        );
    }

    void select(Entity @ent)
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

            { 2.5f },
            { 3.5f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Dash Speed",
            S_COLOR_CYAN,
            "Your dash brings you up to %sx the speed the regular dash would.",
            "Your dash brings you up to %sx the speed the regular dash would",
            " - %sx"
        );
    }

    void select(Entity @ent)
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
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Jump Height",
            S_COLOR_CYAN,
            "You jump %sx higher.",
            "You jump %sx higher",
            " - %sx"
        );
    }

    void select(Entity @ent)
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

            { 0.30f },
            { 0.60f },
            { POWERUP_NUMBERTYPE_PERCENT },

            0.0f, 0.0f,

            "Extra Damage",
            S_COLOR_RED,
            "You deal %s more damage.",
            "You deal %s more damage",
            " - %s"
        );
    }

    void dmg(Entity @ent, const String& in args = "")
    {

        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        float damage = args.getToken(1).toFloat();
        if (@victim.client == null)
            return;
        if (damage > victim.health + victim.client.armor)
            return;

        cPowerUp @pwr = @powerUp[victim.playerNum];
        if ( !( pwr.powerupID == POWERUPID_IMMORTALITY && pwr.ability ) )
            POWERUPS_dealDamageWithArmor(@victim, damage * this.rands[0], @ent);
    }
};

class cPowerUpJetpack : cPowerUp {
    cPowerUpJetpack()
    {
        super(
            POWERUPID_JETPACK,
            0,

            { 1.0f },
            { 2.0f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Jetpack",
            S_COLOR_GREEN,
            "You can fly by holding jump, you can boost by holding special and you can quicky descend by holding crouch. Be wary of your fuel!",
            "You can fly by holding jump and boost by holding special.",
            " - Power: %s",
            POWERUP_HELPMESSAGE_JETPACK
        );
    }

    Entity @jetpack = @G_SpawnEntity("jetpack");

    float fuelMax = 100.0f;
    float fuel = fuelMax;
    bool outOfFuel = false;
    bool lowOnFuel = false;
    bool jetpackActive = false;

    uint regular_pmfeats;

    void select(Entity @ent)
    {
        regular_pmfeats = ent.client.pmoveFeatures;
        ent.client.pmoveFeatures &= ~POWERUP_JETPACK_PMFEATS_NEGATE;
        this.fuel = this.fuelMax;
        ent.mass = rint(ent.mass * 1.5);


        this.jetpack.sound = G_SoundIndex("sounds/weapons/rocket_fly_strong");
        this.jetpack.attenuation = ATTN_NORM;
        this.jetpack.moveType = MOVETYPE_FLY;

        this.jetpack.type = ET_PARTICLES;
        this.jetpack.particlesSpeed = 0;
        this.jetpack.particlesShaderIndex = G_ImageIndex("gfx/misc/smokepuff");
        this.jetpack.particlesSpread = 50;
        this.jetpack.particlesSize = 6;
        this.jetpack.particlesTime = 1;
        this.jetpack.particlesFrequency = 50;
        this.jetpack.particlesSpherical = false;
        this.jetpack.particlesBounce = false;
        this.jetpack.particlesGravity = true;
        this.jetpack.particlesExpandEffect = true;
        this.jetpack.particlesShrinkEffect = false;
        this.jetpack.team = ent.team;
    };

    float getStatFloat()
    {
        return (outOfFuel ? -1 : 1) * (this.fuel / this.fuelMax);
    };

    void think(Entity @ent)
    {
        jetpackActive = false;
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

                jetpackActive = true;
            }
            // cant descend and boost at the same time
            if ( POWERUPS_isKeyPressed(ent.client, KEY_CROUCH) && !POWERUPS_isKeyPressed(ent.client, KEY_SPECIAL) ) {
                newVelocity.z -= 1000 * (frameTime * 0.001f);
                ent.velocity = newVelocity;
                this.fuel -= 2.5 * (frameTime * 0.001f);
            }
            if (POWERUPS_isKeyPressed(ent.client, KEY_SPECIAL)) {
                if ( POWERUPS_isOnGround( @ent ) ) {
                    Vec3 newOrigin = ent.origin;
                    newOrigin.z += 0.5f;
                    ent.origin = newOrigin;
                }

                jetpackActive = true;

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
                secondsToRefuel = 4.0f;
            else
                secondsToRefuel = 5.0f;

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
            int soundindex = G_SoundIndex("sounds/ctftactics/turret_pain01");
            G_LocalSound( ent.client, CHAN_AUTO, soundindex );
        }

        if (this.fuel > this.fuelMax / 10 && lowOnFuel)
            this.lowOnFuel = false;

        if (this.fuel < 0) {
            this.fuel = 0;
            this.outOfFuel = true;
            G_CenterPrintMsg(ent, S_COLOR_RED + "You are out of fuel!");
        }

        ent.velocity = newVelocity;

        this.jetpack.origin = ent.origin;
        this.jetpack.velocity = ent.velocity;

        if ( this.jetpackActive )
            this.jetpack.svflags &= ~SVF_NOCLIENT;
        else
            this.jetpack.svflags |= SVF_NOCLIENT;
    }
    void clearPowerup(Entity @ent)
    {
        ent.client.pmoveFeatures = this.regular_pmfeats;
        this.fuel = 0;

        this.jetpack.freeEntity();
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
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,
            "Extra Knockback",
            S_COLOR_RED,
            "You deal %sx the knockback to enemies.",
            "You deal %sx the knockback to enemies",
            " - %sx"
        );
    }

    Vec3[] victimVelocity(maxClients);

    void select(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = G_GetClient(i).getEnt();
            victimVelocity[i] = victim.velocity;
        };
    }

    void dmg(Entity @ent, const String& in args = "")
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());

        // G_Print(victimVelocity[victim.playerNum].x + " " + victimVelocity[victim.playerNum].y + " " + victimVelocity[victim.playerNum].z + "\n");
        // G_Print(victim.velocity.x + " " + victim.velocity.y + " " + victim.velocity.z + "\n");

        if (@victim.client == null)
            return;

        Vec3 velocityDifference = victim.velocity - victimVelocity[victim.playerNum];

        Vec3 vel = victimVelocity[victim.playerNum];

        vel += velocityDifference * this.rands[0];
        victim.velocity = vel;

        victimVelocity[victim.playerNum] = victim.velocity;
        // G_Print(victim.velocity.x + " " + victim.velocity.y + " " + victim.velocity.z + "\n");
    }

    void think(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = G_GetClient(i).getEnt();
            victimVelocity[i] = victim.velocity;
        };
    }


    // void think(Entity @ent)  {
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

            { 1.0f, 80.0f  },
            { 2.0f, 150.0f },
            { POWERUP_NUMBERTYPE_NUMBER, POWERUP_NUMBERTYPE_INTEGER },

            5.0f, 0.0f,

            "Boom!",
            S_COLOR_ORANGE,
            "You make a powerful explosion with medium range and deal damage to people in close proximity to you.",
            "You make a powerful explosion and deal damage to people in close proximity to you",
            " - Knockback: %sx Damage: %s",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    void onActionPress(Entity @ent)
    {
            if (!checkCooldown(@ent))
                return;
            ent.splashDamage(@ent, 400, this.rands[1], (this.rands[0] * 450), 0, MOD_HIT);
            ent.explosionEffect(200);
    }

    void kill(Entity @ent, const String& in args = "")
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        if (victim.classname == "clone")
            return;
        int mod = args.getToken(3).toInt();
        if ( mod == MOD_HIT )
            ent.client.addAward(S_COLOR_ORANGE + "Boom Frag!");
    }

};
// TODO: toggleable, cut off invis if shooting OR raise length for attack
class cPowerUpInvisibility : cPowerUp {
    cPowerUpInvisibility()
    {
        super(
            POWERUPID_INVISIBILITY,
            G_ImageIndex("gfx/misc/playerspawn"),

            { 1.0f },
            { 1.3f },
            { POWERUP_NUMBERTYPE_NUMBER },
            0.0f, 0.0f,

            "Invisibility",
            S_COLOR_WHITE,
            "You are invisibile while you aren't shooting or in air. You will be visible for %s seconds after you stop shooting or touch the ground, and double that if you are hit.",
            "You are invisibile while you aren't shooting or in air, or being attacked.",
            " - %s seconds"
        );
    }

    uint airtimeStart;

    int[] ammoWeap(WEAP_INSTAGUN);

    void select(Entity @ent)
    {
        ent.svflags |= SVF_ONLYTEAM;
        // ent.client.pmoveFeatures = POWERUP_INVISIBLE_PMFEATS;

        if (gametype.isInstagib) {
            ent.client.inventoryClear();
            ent.client.inventorySetCount(WEAP_GUNBLADE, 1);
            ent.client.inventorySetCount(AMMO_GUNBLADE, 1);
            ent.client.selectWeapon(-1);
        }

        ent.client.armor = 75;

        this.abilityLength = rint(this.rands[0] * 1000);
        ent.client.pmoveMaxSpeed = 450;

        for (uint i = 0; i < ammoWeap.length(); i++)
        {
            ammoWeap[i] = ent.client.inventoryCount( AMMO_GUNBLADE + i );
        }
    }

    // i just want to say i think the EF_RACEGHOST effect looks really cool and is a great indicator of being invisible to your teammates
    void think(Entity @ent)
    {
        if (POWERUPS_isOnGround( @ent ))
        {
            airtimeStart = 0;
        }
        if ( !POWERUPS_isOnGround(@ent) && airtimeStart == 0)
        {
            airtimeStart = levelTime;
        }

        bool enableVisibilityAttack = (POWERUPS_isKeyPressed(ent.client, KEY_ATTACK) && ( ent.weapon == WEAP_GUNBLADE || gametype.isInstagib ) );
        for (uint i = 0; i < ammoWeap.length(); i++)
        {
            //if it has went down by 1
            if ( (ammoWeap[i] == ent.client.inventoryCount( AMMO_GUNBLADE + i ) + 1 ) )
            {
                enableVisibilityAttack = true;
            }
            ammoWeap[i] = ent.client.inventoryCount( AMMO_GUNBLADE + i );
        }
        bool enableVisibilityAirtime = (airtimeStart != 0 && levelTime - airtimeStart > 100 );
        // G_Print((wantsEnableVisibility ? "y" : "n") + "\n");
        if (enableVisibilityAttack || enableVisibilityAirtime ) {
            // is visible
            this.ability = false;
            uint length = rint(this.abilityLength * (enableVisibilityAttack ? 1.25 : 1) );
            if (this.abilityTimeEnd < levelTime + length)
                this.abilityTimeEnd = levelTime + length;

        } else if (this.abilityTimeEnd < levelTime) {
            // is invisible
            this.ability = true;
        }
        if (this.ability)
        {
            ent.effects |= EF_RACEGHOST;
            ent.svflags |= SVF_ONLYTEAM;
            // ent.client.pmoveMaxSpeed = 450;
        }
        else
        {
            ent.effects &= ~EF_RACEGHOST;
            ent.svflags &= ~SVF_ONLYTEAM;
            // ent.client.pmoveMaxSpeed = -1;
        }

/*
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
*/
    }

    float getStatFloat()
    {
        if (!this.ability)
        {
            float abilityBar = ((float(this.abilityTimeEnd) - float(levelTime)) / 1000) / this.rands[0];
            return -abilityBar;
        }
        else
        {
            return 0.0f;
        }
    }


    void tookdmg(Entity @ent, const String& in args = "")
    {
        this.ability = false;
        this.abilityTimeEnd = levelTime + (this.abilityLength) * 2;
    };

    void dmg(Entity @ent, const String& in args = "")
    {
        // negate splash damage done if in instagib
        if (!gametype.isInstagib)
            return;
        Entity @target = @G_GetEntity(args.getToken(0).toInt());
        float damage = args.getToken(1).toFloat();

        if (damage < 9999.0f)
            target.health += damage;
    };

    void sendPowerupMessage(Entity @msgFrom, uint powerupID, String msg = "" )
    {
        float invisShowLength = msg.toFloat();
        this.ability = false;
        this.abilityTimeEnd = levelTime + (rint(invisShowLength * 1000));
    }

};


class cPowerUpQuad : cPowerUp {
    cPowerUpQuad()
    {
        super(
            POWERUPID_QUAD,
            G_ImageIndex("gfx/hud/icons/powerup/quad"),

            { 2.5f, 2.5f },
            { 4.0f, 4.0f },
            { POWERUP_NUMBERTYPE_NUMBER, POWERUP_NUMBERTYPE_NUMBER },
            9.0f, 0.0f,

            "Damage Multiplier",
            S_COLOR_ORANGE,
            "Your damage is multiplied by %sx for %s seconds",
            "Your damage is multiplied by %sx for %s seconds",
            " - %sx for %s seconds",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    void onActionPress(Entity @ent)
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

    void think(Entity @ent)
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

    void dmg(Entity @ent, const String& in args = "")
    {
        if (!ability)
            return;
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        float damage = args.getToken(1).toFloat();
        if (@victim.client == null)
            return;
        if (damage > victim.health + victim.client.armor)
            return;

        // because 1x damage was already done
        POWERUPS_dealDamageWithArmor(@victim, damage * this.rands[0] - 1, @ent);
    };

    void clearPowerup(Entity @ent)
    {
        ability = false;
    };
};

class cPowerUpImmortality : cPowerUp {
    cPowerUpImmortality()
    {
        super(
            POWERUPID_IMMORTALITY,
            G_ImageIndex("gfx/hud/icons/powerup/warshell"),

            { 2.0f },
            { 4.0f },
            { POWERUP_NUMBERTYPE_NUMBER },

            7.5f, 0.0f,

            "Immortality",
            S_COLOR_WHITE,
            "You take no damage for %s seconds.",
            "You take no damage for %s seconds",
            " - %s seconds",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    float health;
    float armor;

    void onActionPress(Entity @ent)
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

    void think(Entity @ent)
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

    void tookdmg(Entity @ent, const String& in args = "")
    {
        if (this.ability) {
            float damage = args.getToken(1).toFloat();
            ent.health += damage;
        }
    };

    void clearPowerup(Entity @ent)
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

            { 1.25f },
            { 2.00f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,


            "Pull Towards",
            S_COLOR_RED,
            "Enemies are pulled towards you when attacked.",
            "Knockback changes to pull enemies towards you when you attack them.",
            " - %sx"
        );
    }

    Vec3[] victimVelocity(maxClients);

    void select(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = G_GetClient(i).getEnt();
            victimVelocity[i] = victim.velocity;
        };
    }

    void dmg(Entity @ent, const String& in args = "")
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());

        // G_Print(victimVelocity[victim.playerNum].x + " " + victimVelocity[victim.playerNum].y + " " + victimVelocity[victim.playerNum].z + "\n");
        // G_Print(victim.velocity.x + " " + victim.velocity.y + " " + victim.velocity.z + "\n");

        if (@victim.client == null)
            return;

        Vec3 velocityDifference = victim.velocity - victimVelocity[victim.playerNum];
        float pullAmount = velocityDifference.length() * this.rands[0];

        Vec3 dir;

        Vec3 VictimOrigin = victim.origin;

        dir = ent.origin - victim.origin;
        dir.normalize();

        if ( POWERUPS_isOnGround(@victim) )
            VictimOrigin.z += 0.1;                             // stop stuck to the ground
        victim.origin = VictimOrigin;


        Vec3 vel = victimVelocity[victim.playerNum];

        vel += dir * pullAmount;
        victim.velocity = vel;

        victimVelocity[victim.playerNum] = victim.velocity;

        // G_Print(victim.velocity.x + " " + victim.velocity.y + " " + victim.velocity.z + "\n");
    }

    void think(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = G_GetClient(i).getEnt();
            victimVelocity[i] = victim.velocity;
          };
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

    void think(Entity @ent)
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

            { 1.75f },
            { 3.0f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f,
            0.0f,

            "Projectile Speed",
            S_COLOR_GREEN,
            "Your projectiles (rocket, grenade, plasma, gunblade blast) are %sx faster.",
            "Your projectiles are %sx faster.",
            " - %sx"
        );
    }


    void think(Entity @ent)
    {
        array<String> projectile_classnames = { "rocket", "grenade", "plasma", "gunblade_blast" };
        for (uint i = 0; i < projectile_classnames.length(); i++) {
            array<Entity @> @ents = G_FindByClassname(projectile_classnames[i]);

            for (uint j = 0; j < ents.length(); j++) {
                if (@ents[j].owner != @ent)
                    continue;
                if (ents[j].target == "fasterProjectile") {
                    ents[j].effects |= EF_GODMODE;
                    continue;
                }
                ents[j].velocity *= this.rands[0];
                ents[j].target = "fasterProjectile"; // tag them to not use them again
            }
        }
    }
};

class cPowerUpFreezeEnemies : cPowerUp {
    cPowerUpFreezeEnemies()
    {
        super(
            POWERUPID_FREEZE_ENEMIES,
            0,

            { 0.2f },
            { 0.3f },
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

    void select(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            frozen[i] = false;
            frozenUntil[i] = 0;
            frozenOrigin[i] = Vec3(0, 0, 0);
            frozenVelocity[i] = Vec3(0, 0, 0);
            regular_pmfeats[i] = G_GetClient(i).pmoveFeatures;
        }
    };

    void dmg(Entity @ent, const String& in args = "")
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        float damage = args.getToken(1).toFloat();

        if (@victim.client == null)
            return;
        if (victim.isGhosting())
            return;

        if (this.rands[0] > random()) {
            float freezeTime = damage / 40;
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

    void clearPowerup(Entity @ent)
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
    void think(Entity @ent)
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

    void sendPowerupMessage(Entity @msgFrom, uint powerupID, String msg = "" )
    {
        if (frozen[msgFrom.playerNum])
        {
            frozenOrigin[msgFrom.playerNum] = msgFrom.origin;
        }
    }

}

class cPowerUpAimbot : cPowerUp {
    cPowerUpAimbot()
    {
        super(
            POWERUPID_AIMBOT,
            G_ImageIndex("gfx/hud/icons/vsay/areasecured"),

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Aimbot",
            S_COLOR_RED,
            "Target an enemy by damaging them, and hold the crouch button to aim at a targeted enemy, but only doing 2/3 damage.",
            "Hold the crouch button to aim at a targeted enemy, at the cost of you doing 2/3 damage",
            "",
            POWERUP_HELPMESSAGE_AIMBOT
        );
    }

    Entity @target = null;

    void select(Entity @ent)
    {
        // ent.client.pmoveFeatures &= ~POWERUP_AIMBOT_PMFEATS_NEGATE;
        ent.client.armor = 25;

    };

    void dmg(Entity @ent, const String& in args = "")
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

    void think(Entity @ent)
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

        if ( actionPressed[ent.playerNum] ) {

            Vec3 mins, maxs;
            target.getSize( mins, maxs );
            Vec3 targetPoint = target.origin;
            targetPoint += 2 * target.velocity * ( 2 * ent.client.ping / 1000);
            // targetPoint.z += target.viewHeight;

            Vec3 currentOrigin = ent.origin + 2 * target.velocity * ( 2 * ent.client.ping / 1000);
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

            currentAngles.x += deltaX * 0.9;
            currentAngles.y += deltaY * 0.9;

            ent.angles = currentAngles;
        }
    };
}

// cant SVF_OWNERANDCHASERS, because Entity.frame and Entity.ownerNum are the same for whatever reason ???
// Recommend to not add this to chooseablePowerupList
class cPowerUpWallhack : cPowerUp {
    cPowerUpWallhack() {
        super(
            POWERUPID_WALLHACK,
            0,

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            0.0f, 0.0f,

            "Team Wallhack",
            S_COLOR_BLUE,
            "Your team can see enemies through walls.",
            "Your team can see enemies through walls",
            ""
        );
    }

    int[] broadcasterEntNum(maxClients);


    void select(Entity @ent)  {
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
            // broadcasterEnt.ownerNum = ent.entNum;
            broadcasterEnt.frame = 64;
            broadcasterEnt.type = ET_RADAR;
            broadcasterEnt.solid = SOLID_NOT;
            broadcasterEnt.modelindex = G_ImageIndex( "gfx/indicators/radar" );
            broadcasterEnt.svflags = ( SVF_BROADCAST | SVF_ONLYTEAM );
            broadcasterEnt.team = (ent.team == TEAM_BETA ? TEAM_ALPHA : TEAM_BETA);

            broadcasterEntNum[i] = broadcasterEnt.entNum;
        }
    };

    void think(Entity @ent)  {
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

    void clearPowerup(Entity @ent)  {
        array<Entity @> @ents = G_FindByClassname( "capture_indicator_sprite" );

        for ( uint i = 0; i < ents.length(); i++ ) {
            if (@ents[i].owner != @ent)
                continue;
            ents[i].freeEntity();

        }

    };
}

// Breaks demos, must skip point where the clone becomes "damageable", but works in regular gameplay
class cPowerUpClone : cPowerUp {
    cPowerUpClone()
    {
        super(
            POWERUPID_CLONE,
            0,

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            5.0f, 0.0f,

            "Clone",
            S_COLOR_YELLOW,
            "Place a clone of yourself which deals 50 damage when attacked",
            "Place a clone of yourself which deals 50 damage when attacked",
            "",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    Entity @clone;

    void clearPowerup(Entity @ent)  {
        array<Entity @> @ents = G_FindByClassname( "clone" );

        for ( uint i = 0; i < ents.length(); i++ ) {
            if (@ents[i].owner != @ent)
                continue;
            ents[i].freeEntity();
        }
    }

    void onActionPress(Entity @ent)
    {
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

        Vec3 ang = ent.angles;
        if (ang.x < -15)
            ang.x = -15;
        if (ang.x > 15)
            ang.x = 15;

        @clone.owner = @ent;

        clone.type = ET_PLAYER;
        clone.moveType = MOVETYPE_TOSS;

        clone.origin = ent.origin;
        clone.angles = ang;
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

        clone.takeDamage = DAMAGE_NO;
        clone.health = 1;

        clone.timeStamp = levelTime;

        @clone.think = POWERUPS_clone_think;
        @clone.pain = POWERUPS_clone_pain;
        @clone.die = POWERUPS_clone_die;
        clone.nextThink = levelTime;

        clone.linkEntity();

        AI::AddGoal(clone);
    }

    void kill(Entity @ent, const String& in args = "")
    {
        int mod = args.getToken(3).toInt();
        if ( mod == MOD_HIT )
            ent.client.addAward(S_COLOR_RED + "Clone Frag!");
    }

}
void POWERUPS_clone_think(Entity @clone) {

    Vec3 mins, maxs;
    clone.getSize( mins, maxs );

    clone.nextThink = levelTime + frameTime;

    if (clone.timeStamp + 500 < levelTime) {                // must be alive for this long to take damage
        clone.takeDamage = DAMAGE_YES;
        // clone.effects &= ~(EF_GODMODE);
        // clone.svflags &= ~SVF_ONLYTEAM;
    }
    else
    {
        // clone.svflags |= SVF_ONLYTEAM;
        // clone.effects |= (EF_GODMODE);
    }
    if (clone.timeStamp + 15000 < levelTime) {                // 15 sec lifetime
        clone.freeEntity();
        return;
    }

    Trace trace;
    bool inWall = trace.doTrace(clone.origin, mins, maxs, clone.origin, clone.entNum, MASK_PLAYERSOLID);
    if (inWall) {
        if (@clone.owner.client != null) {
            cPowerUp @pwr = powerUp[clone.owner.playerNum];
            pwr.cooldownTime = levelTime;
        }
        clone.freeEntity();
    }
}
void POWERUPS_clone_die(Entity @clone, Entity @inflicter, Entity @attacker) {
    if (@clone.owner.client != null) {
        POWERUPS_clone_dealDamageToAttacker(@clone, @clone.owner, @attacker);
    }

    clone.freeEntity();
};
void POWERUPS_clone_pain(Entity @clone, Entity @other, float kick, float damage) {
    if (@clone.owner.client != null) {
        POWERUPS_clone_dealDamageToAttacker(@clone, @clone.owner, @other);
    }

    clone.freeEntity();
};

void POWERUPS_clone_dealDamageToAttacker(Entity @clone, Entity @owner, Entity @attacker) {
    float damage = ( gametype.isInstagib ? 1000.0f : 50.0f);
    attacker.sustainDamage(@clone, @owner, Vec3(0, 0, 0), damage, 0, 0, MOD_HIT);

    String message = "You attacked a clone of " + owner.client.name + S_COLOR_WHITE + "!";
    G_CenterPrintMsg(@attacker, message);
    G_PrintMsg(@attacker, message + "\n");

    message = attacker.client.name + S_COLOR_WHITE + " attacked your clone!";
    G_CenterPrintMsg(@owner, message);
    G_PrintMsg(@owner, message + "\n");
}

class cPowerUpTeleporter : cPowerUp {
    cPowerUpTeleporter()
    {
        super(
            POWERUPID_TELEPORTER,
            0,

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            2.5f, 0.0f,

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

    void select(Entity @ent)
    {
        if (maxClients < 120) {
            G_ConfigString(CS_GENERAL + 2 + ent.playerNum, this.statMessage() + " - Not placed");
        }
    }

    void clearPowerup(Entity @ent)  {
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

    void onActionPress(Entity @ent)
    {

        if (!checkCooldown(@ent))
            return;

        if (@teleporter != null && @teleporter.owner == @ent ) {
            ent.teleportEffect( true );

            ent.origin = teleporter.origin;
            ent.angles = teleporter.angles;

            // send a message to frozen to change origin
            for (int i = 0; i < maxClients; i++) {
                cPowerUp @pwr = @powerUp[i];
                if ( pwr.powerupID == POWERUPID_FREEZE_ENEMIES )
                pwr.sendPowerupMessage( @ent, this.powerupID );
            }

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
                    ent.client.addAward(S_COLOR_YELLOW + "Teleporter Telefrag!");
                }
            }

            if (maxClients < 120) {
                G_ConfigString(CS_GENERAL + 2 + ent.playerNum, this.statMessage() + " - Not placed");
            }

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

        // this doesnt work, but I dont want them to be destroyable
        // teleporterBody.takeDamage = DAMAGE_YES;
        // teleporterBody.health = 50;

        // @teleporterBody.die = @POWERUPS_teleporter_die;

        teleporter.linkEntity();

        if (maxClients < 120) {
            G_ConfigString(CS_GENERAL + 2 + ent.playerNum, this.statMessage() + " - Placed");
        }
    }


}

// void POWERUPS_teleporter_die(Entity @ent, Entity @inflicter, Entity @attacker) {
//     Entity @teleporterBody = @ent;
//     Entity @teleporter = @teleporterBody.owner;
//     Entity @player = @teleporter.owner;
//
//     if (@player != null && @player.client != null) {
//         String msg;
//         if (@attacker.client != null)
//             msg = "Your teleporter was destroyed by " + attacker.client.name + S_COLOR_WHITE + "!";
//         else
//             msg = "Your teleporter was destroyed!";
//
//         G_CenterPrintMsg(player, S_COLOR_RED + msg);
//     }
//     teleporterBody.freeEntity();
//     teleporter.freeEntity();
// };


// TODO: allow for GB
class cPowerUpSelfKnockback : cPowerUp {
    cPowerUpSelfKnockback()
    {
        super(
            POWERUPID_SELFKB,
            0,

            { 1.0f },
            { 1.5f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Self Knockback",
            S_COLOR_GREEN,
            "Shooting pushes you opposite the direction you shot",
            "Shooting pushes you opposite the direction you shot",
            " - %sx",
            ""
        );
    }

    int[] ammoWeap(WEAP_INSTAGUN);

    //                  {GB, MG, RG, GL, RL, PG, LG, EB, IG};
    array<int> kbWeap = { 0,  4, 20, 10, 10,  3,  2, 20, 25};


    void select(Entity @ent)
    {
        for (uint i = 0; i < ammoWeap.length(); i++)
        {
            ammoWeap[i] = ent.client.inventoryCount( AMMO_GUNBLADE + i );
        }
    }
    void think(Entity @ent)
    {
        for (uint i = 0; i < ammoWeap.length(); i++)
        {
            //if it has went down by 1
            if ( (ammoWeap[i] == ent.client.inventoryCount( AMMO_GUNBLADE + i ) + 1 ) )
            {
                // G_Print("weapon " + i + " shot\n");

                Vec3 dir;

                Vec3 fwd, right, up;
                ent.angles.angleVectors(fwd, right, up);
                fwd.normalize();

                ent.velocity += fwd * -30.0f * kbWeap[i] * this.rands[0];
            }
            ammoWeap[i] = ent.client.inventoryCount( AMMO_GUNBLADE + i );
        }
    }
}

// Grapple code taken and adapted from https://github.com/bds1337/grapplinghook/
const int HOOK_IDLE     = 0;

const int HOOK_RELEASE  = 2;
const int HOOK_PULLING  = 3;
const int HOOK_LIMIT_MAX_SPEED  = 2200;

class cPowerUpGrapple : cPowerUp {
    cPowerUpGrapple()
    {
        super(
            POWERUPID_GRAPPLE,
            0,

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            0.0f, 0.0f,

            "Grappling Hook",
            S_COLOR_YELLOW,
            "Hold the action button to grapple.",
            "Hold the action button to grapple.",
            "",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    float staminaMax = 40.0f;
    float stamina = this.staminaMax;
    bool outOfStamina = false;

    float getStatFloat()
    {
        return (this.outOfStamina ? -1 : 1) * this.stamina / this.staminaMax;
    }

    int sndHook = G_SoundIndex( "sounds/items/item_spawn", false );

    Entity @beam;
    Entity @groundEntity;

    Vec3 fwdTarget;

    bool isActive;
    int hookState;

    // Sky, wall, player
    int hookTarget;

    Vec3 hookEndPos;
    Vec3 hookOrigin;

    Vec3 hookBeamPos;

    float hookLength;

    void select(Entity @ent)
    {
        // ent.client.pmoveFeatures &= ~POWERUP_GRAPPLE_PMFEATS_NEGATE;

        @this.beam = @G_SpawnEntity( "hook_beam" );
        this.beam.modelindex = 1;
        this.beam.frame = 8;
        this.beam.type = ET_BEAM;
        // | SVF_PROJECTILE; // SVF_BROADCAST SVF_NOCLIENT
        this.beam.svflags = SVF_BROADCAST | SVF_TRANSMITORIGIN2;
        this.beam.svflags &= ~SVF_NOCLIENT;
        this.beam.moveType = MOVETYPE_TOSS;                 //MOVETYPE_LINEARPROJECTILE;
        this.beam.solid = SOLID_TRIGGER;

        this.beam.linkEntity();

    };

    void PlayerUnstuck( Entity@ hookedPlayer)
    {
        if ( @hookedPlayer.groundEntity != null )
        {
            // hax right here
            Entity @ent = @G_SpawnEntity( ":D" );
            ent.origin = hookedPlayer.origin + Vec3( 0, 0, -20);
            ent.splashDamage( @ent , 25, 0, 35, 0, MOD_EXPLOSIVE );
            // destroy splash entity
            ent.freeEntity();
        }
    }

    void think(Entity @ent)
    {

        Client @client = @ent.client;

        if (stamina <= 0.0f )
        {
            this.outOfStamina = true;
        }
        if (this.outOfStamina)
        {
            if (stamina > ( this.staminaMax * 50) / 100 )
            {
                this.outOfStamina = false;
            }
        }

        if ( actionPressed[ent.playerNum] && !this.outOfStamina)
        {
            this.stamina -= 10.0f * float(frameTime) / 1000.0f;

            Vec3 fwd, _right, _up;
            client.getEnt().angles.angleVectors(fwd, _right, _up);

            this.fwdTarget = fwd;
            // Calculate first position and draw (beam)hook
            if ( this.hookState == HOOK_IDLE )
            {
                // Disable crounching
                client.pmoveFeatures = client.pmoveFeatures & ~( PMFEAT_CROUCH );

                this.hookOrigin = client.getEnt().origin + ent.viewHeight;

                Vec3 player_look;
                player_look = this.hookOrigin + this.fwdTarget * 10000; // hook lenght limit

                Trace tr; // tr.ent: -1 = nothing; 0 = wall; 1 = player
                tr.doTrace( this.hookOrigin, Vec3(), Vec3(), player_look, 0, MASK_SOLID ); //MASK_SHOT MASK_SOLID

                this.hookTarget = tr.surfFlags & SURF_SKY; // = 4 if sky
                this.hookEndPos = tr.get_endPos();

                // Make a "sound" effect
                G_Sound( client.getEnt(), CHAN_AUTO, sndHook, ATTN_DISTANT );

                this.hookBeamPos = this.hookOrigin;

                {
                    this.hookState = HOOK_PULLING;
                    this.beam.set_origin2( this.hookEndPos );
                    PlayerUnstuck( client.getEnt() );
                }
            }

            Vec3 dir, v0, dv, v;
            // Define hook speed scale
            const float hookScale = 30;

            dir = this.hookEndPos - client.getEnt().origin;
            float dist = dir.length();
            dir.normalize();

            if ( this.hookState == HOOK_RELEASE )
            {
                // TODO: pull rope
                // Sets beam entity to end pos

                float newLenght = 0;
                if ( newLenght < dist )
                {
                    this.hookBeamPos = this.hookBeamPos + this.fwdTarget * 40;
                    newLenght = (this.hookBeamPos - client.getEnt().origin).length();
                }
                this.hookLength = newLenght;
                this.beam.set_origin2( this.hookBeamPos );

                if ( newLenght >= dist )
                {
                    this.hookState = HOOK_PULLING;
                    newLenght = 0;

                    if (this.hookTarget == 4)
                    {
                        this.isActive = false;
                        return;
                    }

                    //PlayerUnstuck();
                }
            }
            if ( this.hookState == HOOK_PULLING )
            {
                // cant hook skybox
                if (this.hookTarget == 4)
                {
                    this.isActive = false;
                    return;
                }

                v = client.getEnt().get_velocity();

                if ( dist < 300)
                    v = ( v + dir * hookScale ) * 0.98;
                else
                    v = v + dir * hookScale;

                // TODO: allow gain speed while hook_limit (rocketjumping etc)
                if ( v.length() > HOOK_LIMIT_MAX_SPEED )
                {
                    v.normalize();
                    v = v * HOOK_LIMIT_MAX_SPEED;
                }
                client.getEnt().set_velocity( v );

            }
            // Draw hook beam
            this.beam.svflags &= ~SVF_NOCLIENT;
            this.beam.set_origin( client.getEnt().origin );
        }
        else
        {
            this.beam.svflags |= SVF_NOCLIENT;
            this.hookState = HOOK_IDLE;
            client.pmoveFeatures = client.pmoveFeatures | ( PMFEAT_CROUCH );
            if (this.stamina < this.staminaMax)
                this.stamina += 6.0f * float(frameTime) / 1000.0f;
            if (this.stamina > this.staminaMax)
                this.stamina = this.staminaMax;
        }
    }


    void clearPowerup(Entity @ent)  {
        this.beam.freeEntity();
        this.stamina = 0;
    };
}


class cPowerUpMultiJump : cPowerUp {
    cPowerUpMultiJump()
    {
        super(
            POWERUPID_MULTIJUMP,
            0,

            { 3.0f },
            { 5.0f },
            { POWERUP_NUMBERTYPE_INTEGER },

            0.0f, 0.0f,

            "Air Jump",
            S_COLOR_BLUE,
            "You can jump %s times mid-air by pressing jump while in the air",
            "You can jump %s times mid-air by pressing jump while in the air.",
            " - %s jumps",
            ""
        );
    }

    // uint previousKeys;
    uint airtimeStart = 0;
    int jumpsDone = 0;
    float untilNextJump = 0.0f;
    int maxJumps = rint(floor(this.rands[0]));

    int soundIndex = G_SoundIndex("sounds/world/launchpad");
    void select(Entity @ent)
    {
        // previousKeys = ent.client.pressedKeys;
        // G_Print(this.rands[0] + " " + maxJumps + "\n");
    }

    float getStatFloat()
    {
        float jumpFrac = (float(maxJumps - jumpsDone + untilNextJump) / float(maxJumps));
        if (jumpFrac < ( 1.0f / float(maxJumps) ))
            jumpFrac *= -1;

        return jumpFrac;
    };

    void think(Entity @ent)
    {
        // G_Print("aS:"+airtimeStart+" jD:"+jumpsDone+"\n");
        if ( POWERUPS_isOnGround(@ent) && ( airtimeStart != 0 || jumpsDone != 0 ) )
        {
            // G_Print("Jump reset\n");
            airtimeStart = 0;
        }
        if ( POWERUPS_isOnGround(@ent) && jumpsDone != 0 )
        {
            untilNextJump += 0.01 * frameTime;
        }
        if (untilNextJump >= 1.0f)
        {
            untilNextJump = 0.0f;
            jumpsDone--;
        }
        // G_Print("jD:"+jumpsDone+" uNJ:"+untilNextJump+" mJ:"+maxJumps+"\n");

        if ( !POWERUPS_isOnGround(@ent) && airtimeStart == 0)
        {
            airtimeStart = levelTime;
        }
        // previousKeys = ent.client.pressedKeys;
    }

    void onActionPress(Entity @ent)
    {
        if ( !POWERUPS_isOnGround(@ent) && levelTime - airtimeStart > 150 && jumpsDone < maxJumps )
        {
            jumpsDone++;
            // G_Print("Midair jump " + jumpsDone + "\n");
            Vec3 vel = ent.velocity;
            if (vel.z < 0)
            vel.z = 0;
            vel.z += ent.client.pmoveJumpSpeed;
            ent.velocity = vel;
            airtimeStart = levelTime;
            G_Sound( ent, CHAN_AUTO, soundIndex, 0.5f );
        }
    }

}

// This is somewhat buggy with rockets and plasma, so I disabled them following
class cPowerUpHomingProjectiles : cPowerUp {
    cPowerUpHomingProjectiles()
    {
        super(
            POWERUPID_HOMINGPROJS,
            0,

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_NONE },

            0.0f,
            0.0f,

            "Homing Grenades",
            S_COLOR_BLUE,
            "Your grenades home in on an enemy.",
            "Your grenades home in on an enemy.",
            ""
          );
    }

    void think(Entity @ent)
    {
        // array<String> projectile_classnames = { "rocket", "grenade", "plasma", "gunblade_blast" };
        array<String> projectile_classnames = { "grenade" };
        for (uint i = 0; i < projectile_classnames.length(); i++)
        {
            array<Entity @> @ents = G_FindByClassname(projectile_classnames[i]);

            for (uint j = 0; j < ents.length(); j++)
            {
                if (@ents[j].owner != @ent)
                    continue;

                Entity @target = null;
                bool alreadyHasTarget = false;

                if (!ents[j].target.empty() ) {
                    if ( ents[j].target.toInt() == ent.playerNum )
                        continue;
                    // G_Print(ents[j].target);
                    alreadyHasTarget = true;
                    @target = G_GetClient(ents[j].target.toInt()).getEnt();
                }
                else
                {
                    ents[j].target = ent.playerNum;
                }

                Vec3 start = ents[j].origin;

                if (!alreadyHasTarget)
                {
                    int enemyTeam = ent.team == TEAM_ALPHA ? TEAM_BETA : TEAM_ALPHA;
                    array<int> allPlayers = POWERUPS_teamAlivePlayerList(enemyTeam);
                    for (int k = 0; k < maxClients; k++)
                    {
                        Entity @player = G_GetClient(k).getEnt();

                        if (@player == @ent || player.team == ent.team || player.isGhosting() ) {
                            continue;
                        }
                    }

                    Vec3 fwd, right, up;
                    ent.angles.angleVectors(fwd, right, up);

                    float bestDot = 0.90f;                       // come on, you have to actually look at the player youre targeting!

                    for (uint k = 0; k < allPlayers.length(); k++)
                    {
                        Entity @enemy = G_GetClient(allPlayers[k]).getEnt();
                        if (@enemy == null || enemy.isGhosting())
                            continue;

                        Vec3 dir = enemy.origin - ent.origin;
                        dir.normalize();

                        float dot = fwd.x * dir.x + fwd.y * dir.y + fwd.z * dir.z;
                        if (dot > bestDot)
                        {
                            bestDot = dot;
                            @target = @enemy;
                        }
                    }
                }

                if ( (@target == null || target.isGhosting() || @target.client == null || target.team == ent.team )
                    || ( @powerUp[target.playerNum] != null && powerUp[target.playerNum].powerupID == POWERUPID_INVISIBILITY && powerUp[target.playerNum].ability ) )
                    // || ( alreadyHasTarget && (ents[j].classname == "rocket" || ents[j].classname == "plasma") ) )
                    continue;

                if (!alreadyHasTarget)
                {

                    Trace trace;
                    trace.doTrace(start, Vec3(0, 0, 0), Vec3(0, 0, 0), target.origin, ent.entNum, MASK_SHOT);

                    if (trace.entNum != target.entNum)
                        continue;

                    ents[j].target = target.playerNum;
                }

                Vec3 enemyOrigin = target.origin;

                float distance = start.distance(enemyOrigin);

                Vec3 vel = ents[j].velocity;
                float speed = ents[j].velocity.length();

                if (distance < 2 * speed / frameTime )
                    continue;
                // G_Print(dir.x + " " + dir.y + " " + dir.z + " " + speed + "\n");

                // float moveTime = speed / distance;
                // enemyOrigin += Vec3(target.velocity.x / moveTime, target.velocity.y / moveTime, target.velocity.z / moveTime);


                Vec3 dir = enemyOrigin - start;
                dir.normalize();
                vel = Vec3(dir.x * speed, dir.y * speed, dir.z * speed);

                Vec3 targetAngles = dir.toAngles();
                ents[j].velocity = vel;
                // if (ents[j].classname != "grenade")
                    // ents[j].angles = targetAngles;


                // G_Print("cE: " + closestEnemy.client.name + "\n");

            }
        }
    }
}

class cPowerUpExtraHealth : cPowerUp {
    cPowerUpExtraHealth()
    {
        super(
            POWERUPID_EXTRAHP,
            0,

            { 1.25f },
            { 2.0f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,

            "Extra Health",
            S_COLOR_MAGENTA,
            "You have %sx more health and armor.",
            "You have %sx more health and armor.",
            " - %sx"
        );
    }

    void select(Entity @ent)
    {
        ent.client.armor *= this.rands[0];
        ent.health *= this.rands[0];
        ent.maxHealth = rint(ent.health);
    }
}


class cPowerUpFear : cPowerUp {
    cPowerUpFear()
    {
        super(
            POWERUPID_FEAR,
            0,

            { 1.25f },
            { 2.25f },
            { POWERUP_NUMBERTYPE_NUMBER },
            7.0f, 0.0f,
            "Fear",
            S_COLOR_GREY,
            "You can stop enemies from attacking for %s seconds within a certain radius.",
            "You can stop enemies from attacking for %s seconds within a certain radius.",
            " - %s seconds",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }
    uint[] regular_pmfeats(maxClients);
    int[] prevWeapon(maxClients);
    bool[] feared(maxClients);
    uint[] fearedUntil(maxClients);

    void select(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            feared[i] = false;
            fearedUntil[i] = 0;
            regular_pmfeats[i] = G_GetClient(i).pmoveFeatures;
        }
    };

    void onActionPress(Entity @ent)
    {
        if (!checkCooldown(@ent))
            return;
        int enemyTeam = ent.team == TEAM_ALPHA ? TEAM_BETA : TEAM_ALPHA;
        array<int> allEnemies = POWERUPS_teamAlivePlayerList(enemyTeam);
        int fearedAmount = 0;

        for (uint i = 0; i < allEnemies.length(); i++)
        {
            Entity @victim = G_GetClient(allEnemies[i]).getEnt();
            if (@victim == null || victim.isGhosting())
                continue;

            float dist = ent.origin.distance(victim.origin);
            if (dist > 300.0f)
                continue;

            fearedAmount++;
            G_CenterPrintMsg(victim, "You feel too afraid to attack!");

            cPowerUp @pwr = @powerUp[victim.playerNum];
            if ( pwr.powerupID == POWERUPID_INVISIBILITY )
                pwr.sendPowerupMessage( @ent, this.powerupID, String(this.rands[0]) );
            if ( pwr.powerupID == POWERUPID_FLAMETHROWER )
                pwr.sendPowerupMessage( @ent, this.powerupID, "disallow" );

            feared[victim.playerNum] = true;
            fearedUntil[victim.playerNum] = levelTime + rint(ceil(1000 * this.rands[0]));
            regular_pmfeats[victim.playerNum] = victim.client.pmoveFeatures;
            prevWeapon[victim.playerNum] = victim.weapon;
            victim.client.selectWeapon(WEAP_NONE);
        }
        G_CenterPrintMsg(ent, "You feared " + fearedAmount + " player" + (fearedAmount == 1 ? "" : "s") + "!");
        this.cooldownTime = levelTime + this.cooldownLength + abilityLength;
    }

    void clearPowerup(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = @G_GetClient(i).getEnt();
            if (feared[victim.playerNum]) {

                unfear(@victim);

                G_CenterPrintMsg(victim, ent.client.name + S_COLOR_WHITE + " died, you are no longer afraid!");
                G_PrintMsg(victim, ent.client.name + S_COLOR_WHITE + " died, you are no longer afraid!\n");
            };
        };
    };

    void think(Entity @ent)
    {

        for (int i = 0; i < maxClients; i++) {
            Entity @victim = @G_GetClient(i).getEnt();
            if (feared[victim.playerNum]) {
                victim.client.pmoveFeatures &= ~POWERUP_FEARED_PMFEATS_NEGATE;

                float fearedTime = float(fearedUntil[victim.playerNum] - float(levelTime)) / 1000.0f;
                G_CenterPrintMsg(victim, "You are too afraid to attack for " + POWERUPS_formatFloat(POWERUP_NUMBERTYPE_NUMBER, fearedTime) + " seconds!");
                victim.client.selectWeapon(WEAP_NONE);

                if (fearedUntil[victim.playerNum] < levelTime || victim.isGhosting() ) {
                    unfear(@victim);
                }
            };
        };
    };

    void sendPowerupMessage(Entity @msgFrom, uint powerupID, String msg = "" )
    {
        if (feared[msgFrom.playerNum])
        {
            unfear(@msgFrom);
        }
    }

    void unfear(Entity @unfear)
    {
        unfear.client.pmoveFeatures = regular_pmfeats[unfear.playerNum];
        feared[unfear.playerNum] = false;
        unfear.client.selectWeapon(prevWeapon[unfear.playerNum]);

        G_CenterPrintMsg(unfear, "");

        cPowerUp @pwr = @powerUp[unfear.playerNum];
        if ( pwr.powerupID == POWERUPID_FLAMETHROWER )
            pwr.sendPowerupMessage( null, this.powerupID, "allow" );
    }

}

class cPowerUpReflection : cPowerUp {
    cPowerUpReflection()
    {
        super(
            POWERUPID_REFLECTION,
            0,

            { 0.65f },
            { 0.85f },
            { POWERUP_NUMBERTYPE_PERCENT },

            0.0f, 0.0f,

            "Reflection",
            S_COLOR_WHITE,
            "You reflect %s damage from incoming attacks when used.",
            "You reflect %s damage from incoming attacks when used.",
            " - %s",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    uint reflection = 0;
    float staminaMax = 60.0f;
    float stamina = staminaMax;
    bool outOfStamina = false;

    float health = 250.0f;

    // uint regular_pmfeats;

    void select(Entity @ent)
    {
        // regular_pmfeats = ent.client.pmoveFeatures;
        // ent.client.pmoveFeatures &= ~POWERUP_REFLECTION_PMFEATS_NEGATE;
        this.stamina = this.staminaMax;
        ent.health = 250.0f;
        ent.maxHealth = 250.0f;
        ent.client.armor = 0.0f;
    };

    float getStatFloat()
    {
        return (outOfStamina ? -1 : 1) * (this.stamina / this.staminaMax);
    };

    void think(Entity @ent)
    {
        this.health = ent.health;
        // G_Print(reflection+"\n");
        if ( ( ( actionPressed[ent.playerNum] || ent.client.isBot() ) || reflection != 0 && levelTime - reflection < 500 ) && (!outOfStamina && stamina > 0.0f ))
        {
            if (this.reflection == 0)
            {
                reflection = levelTime;
            }

            ent.effects |= EF_SHELL;

            this.stamina -= 10.0f * (frameTime * 0.001f);
        }
        else
        {
            this.reflection = 0;

            if (stamina <= 0.0f)
            {
                stamina = 0.0f;
                outOfStamina = true;
            }
            float secondsToRefuel = 5.0f;
            this.stamina += (staminaMax / secondsToRefuel) * (frameTime * 0.001f);

            if (stamina > staminaMax)
            {
                stamina = staminaMax;
                outOfStamina = false;
            }

        }

        this.ability = this.reflection > 0;

    }

    void clearPowerup(Entity @ent)
    {
        // ent.client.pmoveFeatures = this.regular_pmfeats;
        this.stamina = 0;
    };

    void tookdmg(Entity @ent, const String& in args = "")
    {
        Entity @attacker = @G_GetEntity(args.getToken(2).toInt());
        Entity @victim = @ent;
        float damage = args.getToken(1).toFloat();
        float reflectionDamage = damage * this.rands[0];
        cPowerUp @pwr = @powerUp[attacker.playerNum];
        if ( pwr.powerupID == POWERUPID_REFLECTION && pwr.ability )
        {
            return;
        }

        int attackerPing = 0;
        if (@attacker != null)
            attackerPing = attacker.client.ping;

        if ( reflection != 0 && int(levelTime - reflection) > attackerPing ) {

            this.stamina -= (this.staminaMax * damage * (1.0f / 3.0f)) / 100;
            // G_Print("REFLECTED "+ damage + " TO " + (damage * this.rands[0]) + "\n");
            ent.health += damage;
            ent.health -= damage - reflectionDamage;

            this.health = ent.health;
            if (@attacker != @victim && @attacker != null )
            {
                G_CenterPrintMsg(attacker, ent.client.name + S_COLOR_WHITE + " reflected your damage!");
                attacker.sustainDamage(@ent, @ent, Vec3(0, 0, 0), reflectionDamage, 0, 0, MOD_HIT);
            }
        }
        // if (int(levelTime - reflection) < attackerPing)
            // G_PrintMsg(attacker, ent.client.name + S_COLOR_WHITE + " reflect Ping-based stop\n");
    }

    void kill(Entity @ent, const String& in args = "")
    {
        int mod = args.getToken(3).toInt();
        if ( mod == MOD_HIT )
        {
            ent.client.addAward(S_COLOR_RED + "Reflection Frag!");
            // Entity @victim = @G_GetEntity(args.getToken(0).toInt());
            // if (@victim.client != null)
            //     victim.client.addAward(S_COLOR_RED + "That one was your fault");
        }
    }

}

class cPowerUpHitSlowdown : cPowerUp {
    cPowerUpHitSlowdown()
    {
        super(
            POWERUPID_HITSLOWDOWN,
            0,

            { 65.0f },
            { 80.0f },
            { POWERUP_NUMBERTYPE_INTEGER },

            0.0f, 0.0f,

            "Hit Slowdown",
            S_COLOR_BLUE,
            "You slow down your enemies proportionate to your damage.",
            "You slow down your enemies proportionate to your damage.",
            " - %s damage to stop"
        );
    }

    Vec3[] victimVelocity(maxClients);

    void select(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = G_GetClient(i).getEnt();
            victimVelocity[i] = victim.velocity;
        };
    }

    void dmg(Entity @ent, const String& in args = "")
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        // G_Print(victimVelocity[victim.playerNum].x + " " + victimVelocity[victim.playerNum].y + " " + victimVelocity[victim.playerNum].z + "\n");
        float damage = args.getToken(1).toFloat();

        if (@victim.client == null)
            return;

        Vec3 vel = victimVelocity[victim.playerNum];
        float mult = 1 - ( damage / ( this.rands[0] ) );
        // G_Print(mult+"\n");
        if (mult < 0)
            mult = 0.0f;
        vel *= mult;
        victim.velocity = vel;
        // G_Print(victim.velocity.x + " " + victim.velocity.y + " " + victim.velocity.z + "\n");

    }

    void think(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = G_GetClient(i).getEnt();
            victimVelocity[i] = victim.velocity;
        };
    }
};

class cPowerUpFlameThrower : cPowerUp {
    cPowerUpFlameThrower()
    {
        super(
            POWERUPID_FLAMETHROWER,
            0,

            { 0.0f },
            { 0.0f },
            { POWERUP_NUMBERTYPE_PERCENT },

            0.0f, 0.0f,

            "Flamethrower",
            S_COLOR_ORANGE,
            "When used, spits out flames in front of you that can burn enemies",
            "When used, spits out flames in front of you that can burn enemies. Also deals afterburn.",
            "",
            POWERUP_HELPMESSAGE_CLASSACTION
        );
    }

    bool canFire = true;

    uint lastBurn = 0;

    uint[] lastAfterBurn(maxClients);
    uint[] afterBurn(maxClients);

    int maxAmmo = 100;
    int ammo = maxAmmo;

    Entity @particle = @G_SpawnEntity("flamethrower");

    void select(Entity @ent)
    {
        for (int i = 0; i < maxClients; i++) {
            lastAfterBurn[i] = 0;
            afterBurn[i] = 0;
        }
        // if (maxClients < 120) {
        //     G_ConfigString(CS_GENERAL + 2 + ent.playerNum, this.statMessage() + " - Ammo: " + ammo );
        // }

        particle.team = ent.team;

        particle.type = ET_PARTICLES;
        particle.moveType = MOVETYPE_FLY;
        particle.sound = G_SoundIndex("sounds/powerups/flamethrower", true);
        particle.attenuation = 1.2f;

        particle.particlesSpeed = 150;
        particle.particlesShaderIndex = G_ImageIndex("flamethrower_particle");
        particle.particlesSpread = 20;
        particle.particlesSize = 10;
        particle.particlesTime = 1;
        particle.particlesFrequency = 30;
        particle.particlesSpherical = false;
        particle.particlesBounce = false;
        particle.particlesGravity = false;
        particle.particlesExpandEffect = false;
        particle.particlesShrinkEffect = false;
        particle.linkEntity();
        @particle.owner = @ent;
    };

    void onActionPress(Entity @ent)
    {
        if ( ammo == 0 && !ent.client.isBot() )
        {
            G_CenterPrintMsg(ent, S_COLOR_RED + "You are out of flamethrower ammo!");

            int soundindex = G_SoundIndex("sounds/weapons/weapon_noammo");
            G_LocalSound( ent.client, CHAN_AUTO, soundindex );
        }
    }

    void think(Entity @ent)
    {
        Vec3 particleOrigin = ent.origin;
        particleOrigin.z += 2 * ent.viewHeight / 3;

        Vec3 fwd, right, up;
        ent.angles.angleVectors(fwd, right, up);
        particleOrigin += fwd * 35.0f;

        particle.origin = particleOrigin;
        particle.angles = ent.angles;
        particle.velocity = ent.velocity;
        if (lastBurn != 0 && levelTime - lastBurn > 100 )
        {
            particle.svflags |= SVF_NOCLIENT;
        }
        if ( canFire && ( actionPressed[ent.playerNum] || ent.client.isBot() ) && levelTime - lastBurn > 100 && ammo > 0 )
        {

            // if (maxClients < 120) {
            //     G_ConfigString(CS_GENERAL + 2 + ent.playerNum, this.statMessage() + " - Ammo: " + ammo );
            // }

            lastBurn = levelTime;
            ammo--;

            if ( ammo == 0 )
            {
                G_CenterPrintMsg(ent, S_COLOR_RED + "You are out of flamethrower ammo!");
            }

            particle.svflags &= ~SVF_NOCLIENT;

            float minDot = 0.8f;
            float maxDist = 300.0f;

            int enemyTeam = ent.team == TEAM_ALPHA ? TEAM_BETA : TEAM_ALPHA;
            array<Entity @> allEnemies = G_FindByClassname("clone");
            array<int> enemyTeamPlayersAlive = POWERUPS_teamAlivePlayerList(enemyTeam);
            for (uint i = 0; i < enemyTeamPlayersAlive.length(); i++)
            {
                Entity @enemy = @G_GetClient(enemyTeamPlayersAlive[i]).getEnt();
                if (@enemy == null || enemy.isGhosting() || enemy.team == ent.team )
                    continue;
                allEnemies.insertLast(@enemy);
            }


            for (uint i = 0; i < allEnemies.length(); i++)
            {
                Entity @enemy = @allEnemies[i];
                if (@enemy == null || enemy.isGhosting() || enemy.team == ent.team )
                    continue;

                float dist = ent.origin.distance(enemy.origin);

                Vec3 dir = enemy.origin - ent.origin;
                dir.normalize();

                float dot = fwd.x * dir.x + fwd.y * dir.y + fwd.z * dir.z;
                if ( dist < maxDist && dot >= minDot )
                {
                    if (enemy.classname != "clone")
                    {
                        lastAfterBurn[enemy.playerNum] = levelTime;
                        afterBurn[enemy.playerNum] = 1;
                    }
                    enemy.sustainDamage(@ent, @ent, dir, 7, 3, 0, MOD_HIT);
                }
            }
        }


        for (int i = 0; i < maxClients; i++) {
            if ( levelTime - lastAfterBurn[i] > 500 && afterBurn[i] <= 3 && afterBurn[i] != 0 )
            {
                Entity @enemy = @G_GetClient(i).getEnt();
                if (@enemy == null || enemy.isGhosting())
                    continue;

                lastAfterBurn[i] = levelTime;
                afterBurn[i]++;
                enemy.sustainDamage(@ent, @ent, Vec3(), 2, 0, 0, MOD_BARREL);
            }
        }
    }

    float getStatFloat()
    {
        return float(ammo) / 100.0f;
    }

    void clearPowerup(Entity @ent) {
        array<Entity @> @ents = G_FindByClassname( "flamethrower" );

        for ( uint i = 0; i < ents.length(); i++ ) {
            if (@ents[i].owner != @ent)
                continue;
            ents[i].freeEntity();
        }
    }

    void sendPowerupMessage(Entity @msgFrom, uint powerupID, String msg = "" )
    {
        if (msg == "allow")
            canFire = true;
        if (msg == "disallow")
            canFire = false;
    }

    void kill(Entity @ent, const String& in args = "")
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());
        if (victim.classname == "clone")
            return;
        int mod = args.getToken(3).toInt();
        if ( mod == MOD_HIT )
            ent.client.addAward(S_COLOR_ORANGE + "Sick Burn!");
    }

};

class cPowerUpAntiKB : cPowerUp {
    cPowerUpAntiKB()
    {
        super(
            POWERUPID_ANTIKB,
            0,

            { 0.25f },
            { 0.50f },
            { POWERUP_NUMBERTYPE_NUMBER },

            0.0f, 0.0f,
            "Anti-Knockback",
            S_COLOR_RED,
            "Enemies deal %sx the knockback to you.",
            "Enemies deal %sx the knockback to you.",
            " - %sx"
        );
    }

    Vec3 selfVelocity = Vec3();

    void select(Entity @ent)
    {
        selfVelocity = ent.velocity;
    }

    void tookdmg(Entity @ent, const String& in args = "")
    {
        Entity @victim = @G_GetEntity(args.getToken(0).toInt());

        // G_Print(selfVelocity.x + " " + selfVelocity.y + " " + selfVelocity.z + "\n");
        // G_Print(victim.velocity.x + " " + victim.velocity.y + " " + victim.velocity.z + "\n");

        if (@victim.client == null)
            return;

        Vec3 velocityDifference = victim.velocity - selfVelocity;

        Vec3 vel = selfVelocity;

        vel += velocityDifference * this.rands[0];
        victim.velocity = vel;

        selfVelocity = victim.velocity;
        // G_Print(victim.velocity.x + " " + victim.velocity.y + " " + victim.velocity.z + "\n");
    }

    void think(Entity @ent)
    {
        selfVelocity = ent.velocity;
    }
};

// utils

void POWERUPS_Respawn( Entity @ent, int old_team, int new_team )
{
    if (@ent == null)
        return;
    if (!POWERUPS_seenWelcomeMessage[ent.playerNum])
    {
        POWERUPS_showWelcomeMessage( @ent.client );
        POWERUPS_seenWelcomeMessage[ent.playerNum] = true;
    }
}

void POWERUPS_showWelcomeMessage( Client @client )
{
    G_PrintMsg( client.getEnt(), S_COLOR_GREEN+"Welcome to "+ gametype.title +"!\n"
        +S_COLOR_YELLOW+"For this gametype, you will need "+S_COLOR_CYAN+"+action"+S_COLOR_YELLOW+" bound.\n"
        +S_COLOR_YELLOW+"You can open the "+S_COLOR_CYAN+"'" + gametype.title + "'"+S_COLOR_YELLOW+" options in the pause menu to set it.\n"
        +S_COLOR_YELLOW+"If you use the "+S_COLOR_CYAN+"adem"+S_COLOR_YELLOW+" or "+S_COLOR_CYAN+"spec"+S_COLOR_YELLOW+" HUD, there is a button in the options to make them work for "+ gametype.title +".\n"
        +S_COLOR_YELLOW+"If you use custom HUDs, make sure you can see progress bars and powerup names. You may have to update it or switch HUDs.\n"
      // +S_COLOR_YELLOW+"If they are unbound, you can open console with the key left of 1 on your keyboard, and type '"
      // +S_COLOR_CYAN+"bind [key] classaction1"+S_COLOR_YELLOW+"' or '"+S_COLOR_CYAN+"bind [key] +quickmenu"+S_COLOR_YELLOW+"'\n"
      );
}

// TODO: Projectiles have different amounts of knockback - Scales with dmg
int POWERUPS_kb_amount_weapon(int weap, float damage)
{
    const int KB_GB = 50;

    const int KB_GB_SPLASH_MAX = 90;
    const int KB_GB_SPLASH_MIN = 10;
    const float DMG_GB_SPLASH_MIN = 8.0f;
    const float DMG_GB_SPLASH_MAX = 35.0f;

    const int KB_MG = 10;

    const int KB_RG = 7;

    const int KB_GL = 100;
    const int KB_GL_SPLASH_MIN = 35;
    const float DMG_GL_MIN = 15.0f;
    const float DMG_GL_MAX = 80.0f;

    const int KB_RL = 100;
    const int KB_RL_SPLASH_MIN = 35;
    const float DMG_RL_MIN = 15.0f;
    const float DMG_RL_MAX = 80.0f;

    const int KB_PG = 20;
    const int KB_PG_SPLASH_MIN = 1;
    const float DMG_PG_MIN = 5.0f;
    const float DMG_PG_MAX = 15.0f;

    const int KB_LG = 14;

    const int KB_EB = 80;

    bool isSplash = POWERUPS_isSplashDamage( weap, damage );

    switch (weap) {

    case WEAP_GUNBLADE:
        if (isSplash) {
            float t = float(damage - DMG_GB_SPLASH_MIN) / float(DMG_GB_SPLASH_MAX - DMG_GB_SPLASH_MIN);
            return rint( KB_GB_SPLASH_MIN + t * float(KB_GB_SPLASH_MAX - KB_GB_SPLASH_MIN) );
        }
        else
            return KB_GB;
    case WEAP_MACHINEGUN:
        return KB_MG;
    case WEAP_RIOTGUN:
        return KB_RG;

    case WEAP_GRENADELAUNCHER:
        if (isSplash) {
            float t = float(damage - DMG_GL_MIN) / float(DMG_GL_MAX - DMG_GL_MIN);
            return rint( KB_GL_SPLASH_MIN + t * float(KB_GL - KB_GL_SPLASH_MIN) );
        }
        else
            return KB_GL;
    case WEAP_ROCKETLAUNCHER:
        if (isSplash) {
            float t = float(damage - DMG_RL_MIN) / float(DMG_RL_MAX - DMG_RL_MIN);
            return rint( KB_RL_SPLASH_MIN + t * float(KB_RL - KB_RL_SPLASH_MIN) );
        }
        else
            return KB_RL;
    case WEAP_PLASMAGUN:
        if (isSplash) {
            float t = float(damage - DMG_PG_MIN) / float(DMG_PG_MAX - DMG_PG_MIN);
            return rint( KB_PG_SPLASH_MIN + t * float(KB_PG - KB_PG_SPLASH_MIN) );
        }
        else
            return KB_PG;

    case WEAP_LASERGUN:
        return KB_LG;
    case WEAP_ELECTROBOLT:
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

bool POWERUPS_isKeyPressed(uint keyPresses, uint key)
{
    return (int(keyPresses) & (1 << key) == (1 << key));
};

bool POWERUPS_isKeyPressed(Client @client, uint key)
{
    return POWERUPS_isKeyPressed(client.pressedKeys, key);
};

String POWERUPS_formatFloat(uint randomNumType, float rand)
{
    String msg = "";
    switch (randomNumType) {
        case POWERUP_NUMBERTYPE_PERCENT:
        msg += StringUtils::FormatFloat(rand * 100, "0", 1, 0) + "%";
            break;

        case POWERUP_NUMBERTYPE_NUMBER:
        msg += StringUtils::FormatFloat(rand, "0", 1, 1);
            break;

        case POWERUP_NUMBERTYPE_INTEGER:
        msg += rint(floor(rand));
            break;

        default:
            break;
      }
    return msg;
}

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

bool POWERUPS_intArrayContains( array<int> ar, int compare )
{
    for (uint i = 0; i < ar.length(); i++)
    {
        if ( ar[i] == compare )
        {
            return true;
        }
    }
    return false;
}

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

    end.z -= 2.0f;

    bool hit = trace.doTrace(start, mins, maxs, end, ent.entNum, MASK_SOLID);

    if (trace.startSolid) {
        return false;
    }

    if (!hit) {
        return false;
    }

    if (trace.planeNormal.z < 0.7f) {
        return false;
    }

    return true;
}

void POWERUPS_dealDamageWithArmor(Entity @ent, float damage, Entity @attacker, uint powerupID = 0) {
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
    if (@ent.client != null && @powerUp[ent.playerNum] != null)
        powerUp[ent.playerNum].tookdmg(@ent, ent.entNum + " " + damage + " " + attacker.entNum + " " + powerupID );
};

void POWERUPS_fakeChatToTeam( int chatPlayerNum, String message, bool teamChat = true ) {
    Entity @chatPlayer = @G_GetClient( chatPlayerNum ).getEnt();
    int teamNum = chatPlayer.team;
    Team @team = @G_GetTeam(chatPlayer.team);
    for ( int i = 0; @team.ent( i ) != null; i++ )
    {
        int recipient = team.ent( i ).playerNum;
        POWERUPS_fakeChat( chatPlayerNum, message, teamChat, recipient );
    }
}

void POWERUPS_fakeChat( int chatPlayerNum, String message, bool teamChat ) {
    for (int i = 0; i < maxClients; i++)
    {
        POWERUPS_fakeChat( chatPlayerNum, message, teamChat, i );
    }
}

void POWERUPS_fakeChat( int chatPlayerNum, String message, bool teamChat, int recipientPlayerNum ) {
    G_GetClient(recipientPlayerNum).execGameCommand( (teamChat ? "t" : "" ) + "ch " + ( chatPlayerNum + 1 ) + " \"" + message + "\"");
};

void POWERUPS_autoteamCommunicate_Kill(Entity @ent, Entity @attacker = null)
{
    if ( ent.client.isBot() || g_powerupca_autocomm.boolean )
    {
        if ( @attacker != null && @attacker.client != null && attacker.team != ent.team ) {
            bool attackerIsDead = attacker.isGhosting();
            int attackerHealth = rint(attacker.health);
            int attackerArmor = rint(attacker.client.armor);
            cPowerUp @attackerPwr = null;

            if (!attackerIsDead) {
                @attackerPwr = @powerUp[attacker.playerNum];
            };

            // POWERUPS_fakeChatToTeam( ent.playerNum, "I was fragged " + ( @attacker.client != null ? "by " + attacker.client.name : "" ) + S_COLOR_YELLOW + " who has " + attackerHealth + " health and " + attackerArmor + " armor. They have the " + attackerPwr.name + " powerup");

            if (!attackerIsDead)
                POWERUPS_fakeChatToTeam( ent.playerNum, ( @attacker.client != null ? attacker.client.name.removeColorTokens() : "" ) + S_COLOR_YELLOW + " " +
                (!gametype.isInstagib ? attackerHealth + " " + attackerArmor + " " : "" ) + attackerPwr.name);
        }
    }
}

void POWERUPS_clearPowerupState(Entity @ent)
{
    if (ent.classname == "clone")
    {
        ent.freeEntity();
        return;
    }
    cPowerUp @pwr = @powerUp[ent.playerNum];
    pwr.clearPowerup(@ent);

    // POWERUPS_clearQuickmenu(@ent);

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

void POWERUPS_setUpQuickmenu(Entity @ent)
{
    GENERIC_SetQuickMenu(@ent.client, "\"Show powerup info\" \"powerups_show\"");
};

String POWERUPS_getPowerupNameByID( uint id )
{
    cPowerUp @pwr = @POWERUPS_getPowerUpByID( id );

    if (pwr.powerupID == POWERUPID_NONE)
        return S_COLOR_WHITE + "None";

    return pwr.color + pwr.name;
}
String POWERUPS_getPowerupDescByID( uint id, bool UseLongDescription = false )
{
    cPowerUp @pwr = @POWERUPS_getPowerUpByID( id );

    return ( UseLongDescription ? pwr.longDescription : pwr.description );
}

String POWERUPS_getRandomPowerupName()
{
    uint id = chooseablePowerupList[POWERUPS_randomInteger(0, chooseablePowerupList.length() - 1)];
    return POWERUPS_getPowerupNameByID( id );
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
};

String POWERUPS_helpmsg_bind(String bind) {
    return S_COLOR_GREEN + bind + S_COLOR_WHITE;
}

void POWERUPS_initialise()
{
    G_PureFile("powerup_assets_001.txt");

    POWERUPS_Command_Register();

    G_ConfigString(CS_HELPMESSAGES + POWERUP_HELPMESSAGE_WELCOME,
    "Welcome to "+gametype.title+"!\n" +
    "Press " + POWERUPS_helpmsg_bind("{Bgametypemenu}") + " to open binding menu."
    );

    G_ConfigString(CS_HELPMESSAGES + POWERUP_HELPMESSAGE_CLASSACTION,
    "Use with " + POWERUPS_helpmsg_bind("{B+action}") + "."
    );

    G_ConfigString(CS_HELPMESSAGES + POWERUP_HELPMESSAGE_JETPACK,
    "Hold " + POWERUPS_helpmsg_bind("{B+moveup}") + " to fly, " + POWERUPS_helpmsg_bind("{B+movedown}") + " to descend and " + POWERUPS_helpmsg_bind("{B+special}") + " to boost."
    );
    G_ConfigString(CS_HELPMESSAGES + POWERUP_HELPMESSAGE_AIMBOT,
    "Target a player by attacking them. Hold " + POWERUPS_helpmsg_bind("{B+action}") + " to look at your target."
    );

    if ( chooseablePowerupList.empty() )                // was not already created by the gametype script

        chooseablePowerupList = {
            POWERUPID_SWAP,
            POWERUPID_INSTA,
            POWERUPID_VAMPIRE,
            POWERUPID_MAXSPEED,
            POWERUPID_DASH,
            // POWERUPID_JUMP,
            POWERUPID_EXTRADMG,
            POWERUPID_JETPACK,
            POWERUPID_EXTRAKB,
            POWERUPID_LAUNCH,
            POWERUPID_INVISIBILITY,
            POWERUPID_QUAD,
            POWERUPID_IMMORTALITY,
            POWERUPID_PULL_TOWARDS,
            // POWERUPID_INFINITE_AMMO,
            POWERUPID_PROJECTILESPEED,
            POWERUPID_FREEZE_ENEMIES,
            // POWERUPID_AIMBOT,
            // POWERUPID_WALLHACK,
            POWERUPID_CLONE,
            POWERUPID_TELEPORTER,
            POWERUPID_SELFKB,
            POWERUPID_GRAPPLE,
            POWERUPID_MULTIJUMP,
            POWERUPID_HOMINGPROJS,
            POWERUPID_EXTRAHP,
            POWERUPID_FEAR,
            POWERUPID_REFLECTION,
            POWERUPID_HITSLOWDOWN,
            POWERUPID_FLAMETHROWER,
            POWERUPID_ANTIKB
        };

        if ( gametype.isInstagib )
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
                POWERUPID_TELEPORTER,
                POWERUPID_GRAPPLE,
                POWERUPID_MULTIJUMP,
                POWERUPID_FEAR
        };

    for (int i = 0; i < maxClients; i++) {
        Client @client = @G_GetClient(i);
        POWERUPS_applyPowerupByID(@client.getEnt(), 0);
        POWERUPS_seenWelcomeMessage[i] = false;
    }
}

void POWERUPS_Think()
{

    for (int i = 0; i < maxClients; i++) {
        Client @client = @G_GetClient(i);
        Entity @ent = @client.getEnt();

        if (client.state() < CS_SPAWNED) {
            POWERUPS_nextRoundID[client.playerNum] = 0;
        }

        if (match.getState() >= MATCH_STATE_POSTMATCH || match.getState() < MATCH_STATE_PLAYTIME) {
            // powerup cooldown
            client.setHUDStat(STAT_PROGRESS_SELF, 0);
            // powerup message
            client.setHUDStat(STAT_MESSAGE_SELF, 0);

            // client.setHUDStat(STAT_IMAGE_SELF, 0);

        } else {
            cPowerUp @pwr = @powerUp[ent.playerNum];

            if (@pwr == null) {
                POWERUPS_applyPowerupByID(ent, POWERUPID_NONE);
                continue;
            }

            if (ent.isGhosting()) {
                if (!client.chaseActive) {
                    // powerup cooldown
                    client.setHUDStat(STAT_PROGRESS_SELF, 0);
                    // powerup message
                    client.setHUDStat(STAT_MESSAGE_SELF, 0);

                    // client.setHUDStat(STAT_IMAGE_SELF, 0 );
                }

                if (pwr.powerupID != POWERUPID_NONE)
                    POWERUPS_clearPowerupState(@ent);
                continue;
            }

            pwr.think(ent);

            client.setHUDStat(STAT_PROGRESS_SELF, rint(pwr.getStatFloat() * 100.0f));
        }
    }
};
