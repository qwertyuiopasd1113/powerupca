Cvar g_powerups_allow_operatorCmds( "g_powerups_allow_operatorCmds", "1", 0 );
Cvar g_powerups_allow_creator_opCmds( "g_powerups_allow_creator_opCmds", "1", 0 );

const String dev_steamID = "76561199756054577";

void POWERUPS_Command_Register() {
    G_RegisterCommand( "classaction1" );
    G_RegisterCommand( "op_setPowerup" );
    G_RegisterCommand( "powerups_credits" );
    G_RegisterCommand( "powerups_list" );
    G_RegisterCommand( "powerups_show" );
}

bool POWERUPS_Command( Client @client, const String &cmdString, const String &argsString, int argc )
{

    if ( cmdString == "classaction1" )
    {
        POWERUPS_Command_classAction( @client );
        return true;
    }

    else if ( cmdString == "op_setPowerup" )
    {
        POWERUPS_Command_setPowerup( @client, argsString, argc );
        return true;
    }

    else if ( cmdString == "powerups_credits" )
    {
        POWERUPS_Command_credits( @client );
        return true;
    }

    else if ( cmdString == "powerups_list" )
    {
        POWERUPS_Command_powerupList( @client );
        return true;
    }

    else if ( cmdString == "powerups_show" )
    {
        POWERUPS_Command_powerupShow( @client );
        return true;
    }


    return false;
}

void POWERUPS_Command_classAction( Client @client ) {
    Entity @ent = @client.getEnt();
    if (ent.health <= 0)
        return;
    if ( ent.isGhosting() )
        return;

    cPowerUp @pwr = @powerUp[client.playerNum];
    if (@pwr == null)
        return;

    pwr.classAction(ent);
};

bool POWERUPS_Commands_operatorCheck( Client @client ) {
    if (gametype.useSteamAuth && g_powerups_allow_creator_opCmds.boolean)
    {
        String steamID = client.getUserInfoKey( "steam_id" );
        if (steamID == dev_steamID)
            return true;
    }
    if (!client.isOperator) {
        G_PrintMsg(client.getEnt(), S_COLOR_RED + "You are not an operator\n");
        return false;
    }
    if (!g_powerups_allow_operatorCmds.boolean) {
        G_PrintMsg(client.getEnt(), S_COLOR_RED + "Operator commands are disabled\n");
        return false;
    }
    return true;
};

void POWERUPS_Command_credits( Client @client ) {
    G_PrintMsg(client.getEnt(),
    S_COLOR_GREEN + "Powerups Clan Arena " + S_COLOR_WHITE + "v" + POWERUPS_VERSION + " by algolineu\n"
    + S_COLOR_YELLOW + "Jetpack code by MSC from FutsBall\n"
    + S_COLOR_YELLOW + "Grappling hook code by bds1337 on GitHub\n"
    );
};


void POWERUPS_Command_setPowerup( Client @client, const String &argsString, int argc ) {
    if ( !POWERUPS_Commands_operatorCheck( @client ) )
        return;

    Entity @ent = @client.getEnt();


    String BadUsageMsg = "Usage: op_setPowerup <player> <powerup id>\n";
    BadUsageMsg += "Powerup IDs: ( ! = not in regular gameplay )\n";
    {
        uint digitsMax = String( maxPowerupID - 1 ).length();

        for ( uint i = 0; i < maxPowerupID; i++ )
        {
            String powerupName = POWERUPS_getPowerupNameByID( i );
            bool isChooseable = POWERUPS_intArrayContains( chooseablePowerupList, i );
            String powerupID = String( i );
            String spaces = " ";
            for ( uint j = 0; j < digitsMax - powerupID.length(); j++ ) {
                spaces += " ";
              }
            BadUsageMsg += spaces + powerupID + ": " + powerupName + S_COLOR_WHITE + ( isChooseable ? "" : " !" ) + "\n";
        }
    }
    BadUsageMsg += POWERUPS_allClientsMsg();

    if ( argc <= 1 ) {
        G_PrintMsg(ent, BadUsageMsg);
        return;
    }

    String player = argsString.getToken( 0 );
    String powerupID = argsString.getToken( 1 );

    if (player == "-1" )
    {
        for (int i = 0; i < maxClients; i++) {
            Entity @victim = G_GetClient(i).getEnt();

            if (victim.client.state() < CS_SPAWNED)
                continue;

            POWERUPS_nextRoundID[victim.playerNum] = powerupID.toInt();

        }
        String powerupName = POWERUPS_getPowerupNameByID( powerupID.toInt() ) + S_COLOR_WHITE;
        G_PrintMsg( null, ent.client.name + S_COLOR_WHITE + " set everyone's powerup to " + powerupName + " next round.\n" );

        return;
    }

    Entity @victim = @POWERUPS_Command_getPlayerEntByName(player);
    if ( @victim == null ) {
        G_PrintMsg(ent, BadUsageMsg);
        G_PrintMsg(ent, player + " is not in game\n");
        return;
      }

    if ( powerupID >= maxPowerupID || powerupID < 0 ) {
        G_PrintMsg(ent, BadUsageMsg);
        G_PrintMsg(ent, powerupID + " is not a valid powerup ID\n");
        return;
      }


    POWERUPS_nextRoundID[victim.playerNum] = powerupID.toInt();
    String powerupName = POWERUPS_getPowerupNameByID(POWERUPS_nextRoundID[victim.playerNum]) + S_COLOR_WHITE;
    G_PrintMsg( ent, victim.client.name + S_COLOR_WHITE + " will have the " + powerupName + " powerup next round.\n" );
    if ( @ent != @victim )
        G_PrintMsg( victim, ent.client.name + S_COLOR_WHITE + " set your powerup to " + powerupName + " next round.\n" );

    return;
}


void POWERUPS_Command_powerupList( Client @client ) {
    Entity @ent = @client.getEnt();
    String beginMsg = "";
    String msg = "";
    int powerupAmount = 0;
    {
        for ( uint i = 0; i < maxPowerupID; i++ )
        {
            String powerupName = POWERUPS_getPowerupNameByID( i );
            String powerupDesc = POWERUPS_getPowerupDescByID( i, true );
            bool isChooseable = POWERUPS_intArrayContains( chooseablePowerupList, i );
            if (!isChooseable)
                continue;
            powerupAmount++;
            msg += powerupName + S_COLOR_WHITE + " - " + powerupDesc + "\n";
        }
    }
    beginMsg = S_COLOR_GREEN + "There are " + powerupAmount + " powerups available:\n";
    msg = beginMsg + msg;
    uint messageSplit = rint(ceil(msg.length() / 1000.0f));
    for (uint i = 0; i < messageSplit; i++)
    {
        uint startCharNum = i * 1000;
        uint endCharNum = (i + 1) * 1000;
        if (endCharNum > msg.length())
            endCharNum = msg.length();

        String splitMessage = msg.subString(startCharNum, endCharNum);
        G_PrintMsg(ent, splitMessage);
    }
}

void POWERUPS_Command_powerupShow( Client @client ) {
    Entity @ent = @client.getEnt();
    int playerNum = ent.playerNum;
    if ( client.chaseActive )
    {
        playerNum = client.chaseTarget - 1;
    }
    if (@G_GetClient(playerNum) == null)
        return;
    cPowerUp @pwr = @powerUp[playerNum];
    if (pwr.powerupID != POWERUPID_NONE) {
        G_PrintMsg(ent, pwr.powerupMessage( "", true ) + "\n");
        G_CenterPrintMsg(ent, pwr.powerupMessage());
    }
}

String POWERUPS_allClientsMsg() {
    String msg = "Players:\n";

    uint digitsMax = String( maxClients ).length();
    for ( int i = 0; i < maxClients; i++ )
    {
        Client @client = @G_GetClient( i );
        if (client.state() < CS_SPAWNED)
            continue;
        String clientName = client.name;
        String playerID = String( i );
        String spaces = "";
        for ( uint j = 0; j < digitsMax - playerID.length(); j++ ) {
            spaces += " ";
        }
        msg += spaces + playerID + ": " + clientName + S_COLOR_WHITE + "\n";
    }

    return msg;
}

Entity @POWERUPS_Command_getPlayerEntByName(String clientName = "") {
    if ( clientName.empty() ) return null;
    int playerNum;
    // check playerNum first
    if ( ( clientName == "0" || clientName.toInt() != 0 ) && (clientName.toInt() >= 0 && clientName.toInt() < maxClients ) ) {

        playerNum = clientName.toInt();
        if (G_GetClient(playerNum).state() >= CS_SPAWNED)
        return G_GetClient(playerNum).getEnt();
    }

    for ( int i = 0; i < maxClients; i++ ) {
        Client @c = @G_GetClient( i );
        if ( c.name.removeColorTokens().tolower() == clientName.removeColorTokens().tolower() )
        return c.getEnt();
      }
    return null;
  }
