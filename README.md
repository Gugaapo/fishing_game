# Fishing Game - Menu System

This project now includes a complete menu system for the fishing game.

## Menu Structure

### Main Menu
- **Start Adventure**: Takes you to the events selection scene
- **Events**: Takes you to the events selection scene
- **Debug Scene**: Takes you to the debug fishing scene
- **Settings**: Opens the settings menu
- **Exit**: Closes the game

### Settings Menu
- **Music Volume**: Adjust music volume (0-100%)
- **SFX Volume**: Adjust sound effects volume (0-100%)
- **Show Controls**: Displays game controls in a popup
- **Back**: Returns to the previous menu

### Pause Menu (In-Game)
- **Resume**: Continues the current game
- **Settings**: Opens the settings menu
- **To Menu**: Returns to the main menu

## Controls

- **ESC**: Pause/unpause the game (when in game scenes)
- **Arrow Keys/WASD**: Navigate menus and move the boat
- **Enter**: Confirm menu selections
- **Mouse**: Click buttons and interact with UI elements

## Scenes

- `main_menu.tscn`: The starting screen
- `game.tscn`: Main fishing game scene
- `Events_scene/events.tscn`: Events selection scene
- `fishing_scene/debug_scene.tscn`: Debug fishing scene
- `settings.tscn`: Settings configuration screen

## Scripts

- `scripts/menu_scripts/main_menu.gd`: Main menu controller
- `scripts/menu_scripts/settings.gd`: Settings menu controller
- `scripts/game_controller.gd`: Main game scene controller
- `scripts/fishing_scripts/debug_scene_controller.gd`: Debug scene controller

## Features

- **Volume Control**: Adjustable music and SFX volume
- **Controls Display**: Shows game controls in a popup
- **Scene Navigation**: Easy navigation between different game modes
- **Pause System**: ESC key pauses the game and shows pause menu
- **Persistent Settings**: Settings are remembered between sessions (basic implementation)

## How to Use

1. **Start the Game**: Run the project and you'll see the main menu
2. **Navigate**: Use arrow keys or mouse to navigate menus
3. **Start Adventure**: Click "Start Adventure" to begin the events sequence
4. **Pause**: Press ESC during gameplay to pause
5. **Adjust Settings**: Use the settings menu to customize your experience
6. **Access Different Scenes**: Use the menu to switch between game modes

## Technical Notes

- The pause menu is automatically added to all game scenes
- Settings are currently stored in memory (can be extended to use ConfigFile)
- Volume controls are prepared for AudioServer integration
- All scenes maintain their pause menu functionality
