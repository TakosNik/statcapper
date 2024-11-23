# **Statcapper**

Statcapper is a World of Warcraft addon designed for the Wrath of the Lich King (3.3.5) client. It provides a customizable window that displays your class-specific stats, their caps, and whether they are capped or not. It also lists your active talents, giving you quick access to essential information to optimize your character.

---

## **Features**
- Detects your character's class and specialization.
- Displays relevant stats for your class and spec (e.g., Hit, Expertise, Crit, Haste).
- Compares your current stats to their caps and indicates whether they are capped.
- Lists your active talent distribution.
- A small, movable, and draggable window for easy customization.

---

## **Installation**
1. Download the Statcapper addon files.
2. Extract the files into your `World of Warcraft/Interface/AddOns/Statcapper` directory.
3. Launch WoW.
4. At the character selection screen, click on "AddOns" and ensure Statcapper is enabled. If you're on a private server, check "Load out of date addons."
5. Log in and enjoy!

---

## **How to Use**
1. After logging in, you'll see a small window titled "Statcapper."
2. The window will display:
   - Your class.
   - Your active talent distribution across talent trees.
   - Your stats, their current values, and whether they are capped.
3. Drag and move the window to your preferred location.
4. The addon updates automatically as you change gear or talents.

---

## **Supported Classes**
- All WoW classes are supported.
- Stat caps are currently defined for:
  - **Warrior:** Hit (8%), Expertise (26).
  - **Mage:** Spell Hit (17%).
  - *Other classes/specs can be added easily.* (See the `statCaps` table in `Statcapper.lua` for details.)

---

## **Known Issues**
- Some stats or caps might not yet be defined for certain classes/specs. Feel free to customize the `statCaps` table in `Statcapper.lua`.
- The window design is basic; future updates may include better visuals.

---

## **Customization**
If you'd like to add custom stat caps or modify functionality:
1. Open `Statcapper.lua` in a text editor.
2. Edit the `statCaps` table to include your desired stats and caps.

Example:
```lua
statCaps["HUNTER"] = { Hit = 8, Crit = 30 } -- Add caps for Hunters
