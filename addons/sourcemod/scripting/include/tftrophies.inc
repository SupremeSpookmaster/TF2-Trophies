#if defined _tftrophies_included_
  #endinput
#endif
#define _tftrophies_included_

/**
 * Called when the Trophy System attempts to hand out a trophy at the end of the round.
 *
 * @param trophy			The name of the trophy, IE "My Cool Trophy".
 * @param winner			The client who should win the trophy. You MUST set this to a valid client if you do not return Plugin_Handled.
 *
 * @return Plugin_Handled or Plugin_Stop to stop the trophy from being awarded, otherwise change "winner" to the client who should win this trophy and return any value other than Plugin_Handled.
 */
forward Action TFTrophies_OnTrophyAwarded(char trophy[255], int &winner);

/**
 * Retrieves an int value from data/tf2_trophies.cfg, associated with the given trophy.
 *
 * @param trophy			The name of the trophy, IE "My Cool Trophy".
 * @param arg				The name of the arg, IE "my_cool_arg".
 * @param defaultVal		The default value to be returned if no value is found.
 *
 * @return The int value associated with the given trophy and arg, or defaultVal if no such value was found.
 */
native TFTrophies_GetArgI(char trophy[255], char arg[255], int defaultVal = 0);

/**
 * Retrieves a float value from data/tf2_trophies.cfg, associated with the given trophy.
 *
 * @param trophy			The name of the trophy, IE "My Cool Trophy".
 * @param arg				The name of the arg, IE "my_cool_arg".
 * @param defaultVal		The default value to be returned if no value is found.
 *
 * @return The float value associated with the given trophy and arg, or 0.0 if no such value was found.
 */
native float TFTrophies_GetArgF(char trophy[255], char arg[255], float defaultVal = 0.0);

/**
 * Retrieves a string value from data/tf2_trophies.cfg, associated with the given trophy.
 *
 * @param trophy			The name of the trophy, IE "My Cool Trophy".
 * @param arg				The name of the arg, IE "my_cool_arg".
 * @param output			Output buffer.
 *
 * @return The string value associated with the given trophy and arg, stored in the output buffer. Returns an empty string if no such value is found.
 */
native void TFTrophies_GetArgS(char trophy[255], char arg[255], char output[255]);

/**
 * Immediately distributes trophies, regardless of whether the round has ended or not.
 */
native void TFTrophies_GiveTrophies();