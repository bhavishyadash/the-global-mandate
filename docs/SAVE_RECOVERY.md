# Recovering a prototype save

The game uses one single-country slot, `prototype_save.json`, in Godot's user data folder for **The Global Mandate**. On Windows the default location is `%APPDATA%\Godot\app_userdata\The Global Mandate\`. The World Lab uses the separate `experimental_world_save.json` slot in the same folder, with its own `.bak`, `.tmp`, `.invalid` and `.bak.previous` files. Its load button loads only its primary slot; backup recovery remains manual. Never substitute a lab save for the single-country save or vice versa.

If saving reports an interrupted temporary save or backup rotation:

1. Close the game and make a copy of the entire save folder in a safe location. Keep all files until you have verified recovery.
2. `prototype_save.json` is the primary slot; `.bak` is the previous valid primary; `.tmp` may contain an unfinished candidate; `.bak.previous` may be an older backup; `.invalid` is a primary found invalid before a later successful save. These files can be incomplete if the process was interrupted.
3. Start the game and try **Load**, then **Load backup** if the primary fails. Check the displayed date, scenario and state. Loading does not overwrite the files. The buttons do not automatically load `.tmp` or `.bak.previous`.
4. If neither load works, preserve the copied folder and inspect the files before choosing a candidate. A candidate can be copied into the primary slot only after making the separate backup in step 1. Open it with the game's loader and verify the state before resuming or saving. Do not assume `.tmp` is complete merely because it exists.
5. A remaining `.tmp`, `.bak.previous` or `.invalid` can block later saves to prevent overwriting evidence. After a verified recovery and a separate backup, move the obsolete artifact out of the save folder. Keep the recovery copy until satisfied.

These steps describe manual recovery. The prototype does not guarantee recovery from sudden power loss, storage failure or a failed rollback, and it does not perform filesystem durability guarantees.
