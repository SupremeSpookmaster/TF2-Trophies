<div align="center"> <h1>TF2 Trophies</h1>

A very simple SourceMod plugin which hands out "Trophies" in the form of post-round chat messages, based on conditions which developers can configure and create. It is incredibly lightweight, very easy to customize, and will work seamlessly with any game mode.

</div>

<p align="center">
  <img src="https://github.com/SupremeSpookmaster/TF2-Trophies/assets/91989209/e2aa54b7-e887-453c-a106-ea506eef4926">
</p>

# *Installation/Update Guide*

1. Download the Latest Release Installation Build (LINK PENDING).
2. Extract the contents of the installation build to your server's `tf/sourcemod` directory.
3. The Trophy System should now be active on your server.
4. To update your server's version of the Trophy System, simply repeat these steps with the Latest Release Update Build. Currently, this plugin is version 1.0, so there is no update build.

# *Trophy Creation Guide*

You may have noticed that, despite the Trophy System being installed on your server, it isn't doing anything. This is because you do not have any Trophies currently active. To create a Trophy, simply follow these steps:

1. Create your Trophy templates in [data/tf2_trophies.cfg](https://github.com/SupremeSpookmaster/TF2-Trophies/blob/main/addons/sourcemod/data/tf2_trophies.cfg).
2. Add your Trophy's message and phrase to [translations/tf2_trophies.phrases.txt](https://github.com/SupremeSpookmaster/TF2-Trophies/blob/main/addons/sourcemod/translations/tf2_trophies.phrases.txt). The name of the Trophy as specified in `tf2_trophies.cfg` will be the phrase you use here. The `{1}` in your phrase's translation refers to the username of the client who won the Trophy. If you want to print extra details to the screen (IE, a damage trophy that shows how much damage the winner dealt), your Trophy's code will need to do that on its own.
3. Write a basic plugin to track the variables and stats needed for your Trophy to be awarded.
4. In your Trophy's plugin, use the `TFTrophies_OnTrophyAwarded` forward to make sure your Trophy is awarded to the correct player when the round ends.
5. Some custom game modes may bypass TF2's vanilla round-end event. In cases like these, simply make sure your game mode calls `TFTrophies_GiveTrophies` in its custom round-end event.

If you need a point of reference for writing your Trophy's plugin, see the [Example Trophy Plugin](https://github.com/SupremeSpookmaster/TF2-Trophies/blob/main/addons/sourcemod/scripting/tftrophies_example.sp). You may also view the [Developer Forwards and Natives](https://github.com/SupremeSpookmaster/TF2-Trophies/wiki/Developer-Forwards-and-Natives) page of this GitHub's Wiki for further assistance.

</div>
