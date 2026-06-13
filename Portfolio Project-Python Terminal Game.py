"""
THE LOST TREASURE OF CODE ISLAND
A Text-Based Adventure Game
Created for CS 101 Portfolio Project
"""

import random
import time

# ========== CLASSES ==========
class Player:
    """Represents the player in the game"""
    def __init__(self, name):
        self.name = name
        self.health = 100
        self.inventory = []
        self.score = 0
        self.has_map = False
    
    def add_item(self, item):
        self.inventory.append(item)
        print(f"✨ You obtained: {item}!")
    
    def take_damage(self, amount):
        self.health -= amount
        print(f"💔 You lost {amount} health! Health: {self.health}")
    
    def heal(self, amount):
        self.health = min(100, self.health + amount)
        print(f"❤️ You gained {amount} health! Health: {self.health}")
    
    def is_alive(self):
        return self.health > 0
    
    def show_status(self):
        print("\n" + "="*40)
        print(f"👤 {self.name}")
        print(f"❤️ Health: {self.health}/100")
        print(f"⭐ Score: {self.score}")
        print(f"🎒 Inventory: {', '.join(self.inventory) if self.inventory else 'Empty'}")
        print("="*40)
    
    def __repr__(self):
        return f"Player('{self.name}', Health={self.health}, Score={self.score})"


class Room:
    """Represents a location in the game"""
    def __init__(self, name, description):
        self.name = name
        self.description = description
        self.exits = {}
        self.item = None
        self.enemy = None
    
    def add_exit(self, direction, room):
        self.exits[direction] = room
    
    def add_item(self, item):
        self.item = item
    
    def add_enemy(self, enemy_name, enemy_health, enemy_damage):
        self.enemy = {"name": enemy_name, "health": enemy_health, "damage": enemy_damage}
    
    def describe(self):
        print(f"\n📍 {self.name}")
        print(self.description)
        if self.item:
            print(f"📦 You see a {self.item} here.")
        if self.enemy and self.enemy["health"] > 0:
            print(f"⚠️ A wild {self.enemy['name']} blocks your path!")
        print(f"\n🚪 Exits: {', '.join(self.exits.keys())}")


# ========== GAME FUNCTIONS ==========
def typewriter_print(text, delay=0.03):
    """Prints text one character at a time for dramatic effect"""
    for char in text:
        print(char, end='', flush=True)
        time.sleep(delay)
    print()

def slow_print(text, delay=0.05):
    """Alternative slow printing function"""
    for char in text:
        print(char, end='', flush=True)
        time.sleep(delay)
    print()

def combat(player, enemy):
    """Handle combat between player and enemy"""
    print(f"\n⚔️ COMBAT STARTED! ⚔️")
    print(f"You face a {enemy['name']} with {enemy['health']} health!")
    
    while player.is_alive() and enemy["health"] > 0:
        print("\nWhat will you do?")
        print("1. ⚔️ Attack")
        print("2. 🏃 Run away")
        print("3. 🎒 Use item")
        
        choice = input("> ")
        
        if choice == "1":
            # Player attacks
            damage = random.randint(15, 30)
            enemy["health"] -= damage
            print(f"You strike the {enemy['name']} for {damage} damage!")
            
            if enemy["health"] <= 0:
                print(f"🎉 You defeated the {enemy['name']}!")
                player.score += 50
                return True
            
            # Enemy attacks back
            enemy_damage = random.randint(5, enemy["damage"])
            player.take_damage(enemy_damage)
            
            if not player.is_alive():
                return False
        
        elif choice == "2":
            # Run away
            if random.random() > 0.5:
                print("🏃 You successfully escaped!")
                return None
            else:
                print("❌ You failed to escape!")
                enemy_damage = random.randint(10, enemy["damage"])
                player.take_damage(enemy_damage)
                if not player.is_alive():
                    return False
        
        elif choice == "3":
            # Use item
            if "Health Potion" in player.inventory:
                player.inventory.remove("Health Potion")
                player.heal(30)
            else:
                print("💊 You have no health potions!")
        
        else:
            print("Invalid choice!")
    
    return False


def play_game():
    """Main game function"""
    # Welcome screen
    print("\n" + "="*50)
    typewriter_print("🏝️ THE LOST TREASURE OF CODE ISLAND 🏝️", 0.05)
    print("="*50)
    typewriter_print("\nYou wake up on a mysterious island...")
    typewriter_print("Legend says a great treasure is hidden somewhere deep within.")
    typewriter_print("Your mission: Find the treasure before you run out of time!\n")
    
    # Get player name
    player_name = input("What is your name, adventurer? > ")
    player = Player(player_name)
    typewriter_print(f"\nWelcome, {player.name}! Your journey begins now...")
    
    # Build the game world
    beach = Room("Sandy Beach", "A beautiful beach with crystal blue water. Palm trees sway in the breeze.")
    jungle = Room("Jungle Path", "A dense jungle path filled with exotic plants and strange sounds.")
    cave = Room("Dark Cave", "A dark, damp cave. You can hear dripping water echoing off the walls.")
    ruins = Room("Ancient Ruins", "Crumbling stone structures covered in mysterious symbols.")
    temple = Room("Hidden Temple", "An ancient temple glowing with a mysterious light. The treasure must be here!")
    
    # Add exits
    beach.add_exit("north", jungle)
    jungle.add_exit("south", beach)
    jungle.add_exit("east", cave)
    jungle.add_exit("north", ruins)
    cave.add_exit("west", jungle)
    ruins.add_exit("south", jungle)
    ruins.add_exit("east", temple)
    temple.add_exit("west", ruins)
    
    # Add items
    beach.add_item("Map")
    jungle.add_item("Health Potion")
    cave.add_item("Golden Key")
    ruins.add_item("Health Potion")
    
    # Add enemies
    jungle.add_enemy("Wild Boar", 40, 15)
    cave.add_enemy("Giant Bat", 30, 12)
    ruins.add_enemy("Stone Guardian", 60, 20)
    
    # Game state
    current_room = beach
    game_over = False
    treasure_found = False
    
    # Main game loop
    while not game_over and player.is_alive():
        current_room.describe()
        
        # Check for items
        if current_room.item:
            take = input(f"\nDo you want to take the {current_room.item}? (yes/no) > ").lower()
            if take == "yes":
                player.add_item(current_room.item)
                if current_room.item == "Map":
                    player.has_map = True
                current_room.item = None
        
        # Check for enemies
        if current_room.enemy and current_room.enemy["health"] > 0:
            result = combat(player, current_room.enemy)
            if result == False:  # Player died
                game_over = True
                break
            elif result == True:  # Enemy defeated
                current_room.enemy = None
        
        # Check for win condition
        if current_room.name == "Hidden Temple":
            if "Golden Key" in player.inventory:
                typewriter_print("\n🔓 You use the Golden Key to open the temple's chest...")
                typewriter_print("✨✨✨ INSIDE LIES THE LEGENDARY TREASURE! ✨✨✨")
                typewriter_print("🏆 You have completed your quest! 🏆")
                player.score += 100
                treasure_found = True
                game_over = True
                break
            else:
                typewriter_print("\n🔒 The temple entrance is locked. You need a Golden Key to enter.")
        
        # Get player action
        if not game_over:
            action = input("\nWhat do you want to do? (north/south/east/west/inventory/status/quit) > ").lower()
            
            if action in current_room.exits:
                current_room = current_room.exits[action]
                typewriter_print(f"\nYou move {action}...")
            elif action == "inventory":
                print(f"\n🎒 Inventory: {', '.join(player.inventory) if player.inventory else 'Empty'}")
            elif action == "status":
                player.show_status()
            elif action == "quit":
                print("\nThanks for playing! Goodbye!")
                game_over = True
            else:
                print("You can't go that way!")
    
    # Game over screen
    print("\n" + "="*50)
    if treasure_found:
        typewriter_print(f"🎉🎉🎉 CONGRATULATIONS, {player.name}! 🎉🎉🎉")
        typewriter_print(f"You found the treasure and escaped with {player.score} points!")
    elif not player.is_alive():
        typewriter_print(f"💀 GAME OVER - {player.name} has perished... 💀")
        typewriter_print(f"Final score: {player.score}")
    else:
        typewriter_print(f"Thanks for playing, {player.name}!")
        typewriter_print(f"Final score: {player.score}")
    
    print("="*50)


# ========== MAIN GAME EXECUTION ==========
if __name__ == "__main__":
    play_game()