import random

# CLASS 1: Creature (like a Pokémon)
class Creature:
    def __init__(self, name, creature_type, hp, attack_power):
        self.name = name
        self.creature_type = creature_type  # e.g., Fire, Water, Grass
        self.hp = hp
        self.max_hp = hp
        self.attack_power = attack_power
    
    def attack(self, other_creature):
        """Attack another creature"""
        damage = random.randint(self.attack_power - 5, self.attack_power + 5)
        other_creature.hp -= damage
        print(f"{self.name} attacks {other_creature.name} for {damage} damage!")
        return damage
    
    def heal(self):
        """Heal the creature"""
        heal_amount = random.randint(10, 30)
        self.hp = min(self.max_hp, self.hp + heal_amount)
        print(f"{self.name} heals for {heal_amount} HP!")
        return heal_amount
    
    def is_alive(self):
        """Check if creature is still alive"""
        return self.hp > 0
    
    def __repr__(self):
        return f"Creature('{self.name}', '{self.creature_type}', HP={self.hp}/{self.max_hp}, ATK={self.attack_power})"
    
    def get_status(self):
        """Return a simple status string"""
        return f"{self.name} [{self.creature_type}] - HP: {self.hp}/{self.max_hp}"


# CLASS 2: Trainer
class Trainer:
    def __init__(self, name, age):
        self.name = name
        self.age = age
        self.team = []  # List of Creature objects
        self.badges = 0
        self.money = 100
    
    def add_creature(self, creature):
        """Add a creature to the trainer's team"""
        if len(self.team) < 6:
            self.team.append(creature)
            print(f"{self.name} caught {creature.name}!")
            return True
        else:
            print(f"{self.name}'s team is full!")
            return False
    
    def remove_creature(self, creature_name):
        """Remove a creature from the team by name"""
        for creature in self.team:
            if creature.name.lower() == creature_name.lower():
                self.team.remove(creature)
                print(f"{self.name} released {creature.name}.")
                return True
        print(f"No creature named {creature_name} found.")
        return False
    
    def choose_creature(self):
        """Let the trainer choose which creature to send out"""
        if not self.team:
            print(f"{self.name} has no creatures!")
            return None
        
        print(f"\n{self.name}'s team:")
        for i, creature in enumerate(self.team, 1):
            print(f"{i}. {creature.get_status()}")
        
        while True:
            try:
                choice = int(input(f"{self.name}, choose a creature (1-{len(self.team)}): "))
                if 1 <= choice <= len(self.team):
                    return self.team[choice - 1]
                else:
                    print("Invalid choice. Try again.")
            except ValueError:
                print("Please enter a number.")
    
    def earn_badge(self):
        """Earn a badge for winning a battle"""
        self.badges += 1
        print(f"{self.name} earned a badge! Total badges: {self.badges}")
    
    def __repr__(self):
        return f"Trainer('{self.name}', {self.age}, {len(self.team)} creatures, {self.badges} badges, ${self.money})"
    
    def get_info(self):
        """Return trainer info string"""
        creature_names = [c.name for c in self.team]
        return f"Trainer {self.name} (age {self.age}) | Badges: {self.badges} | Money: ${self.money} | Team: {creature_names}"


# BATTLE FUNCTION (interaction between the two classes)
def battle(trainer1, trainer2):
    """Simulate a battle between two trainers"""
    print("\n" + "="*50)
    print(f"⚔️ BATTLE START: {trainer1.name} vs {trainer2.name} ⚔️")
    print("="*50)
    
    # Each trainer chooses a creature
    creature1 = trainer1.choose_creature()
    creature2 = trainer2.choose_creature()
    
    if not creature1 or not creature2:
        print("Battle cannot continue - missing creatures!")
        return
    
    print(f"\n{creature1.name} vs {creature2.name}!")
    print("FIGHT!\n")
    
    # Battle loop
    turn = 0
    while creature1.is_alive() and creature2.is_alive():
        turn += 1
        print(f"\n--- Turn {turn} ---")
        
        # Random who goes first
        if random.random() > 0.5:
            creature1.attack(creature2)
            if creature2.is_alive():
                creature2.attack(creature1)
        else:
            creature2.attack(creature1)
            if creature1.is_alive():
                creature1.attack(creature2)
        
        print(creature1.get_status())
        print(creature2.get_status())
    
    # Determine winner
    print("\n" + "="*30)
    if creature1.is_alive():
        print(f"🏆 {creature1.name} wins the battle for {trainer1.name}! 🏆")
        trainer1.earn_badge()
        trainer1.money += 50
        trainer2.money -= 25
    else:
        print(f"🏆 {creature2.name} wins the battle for {trainer2.name}! 🏆")
        trainer2.earn_badge()
        trainer2.money += 50
        trainer1.money -= 25
    
    print("="*30)


# DEMO AND TESTING
if __name__ == "__main__":
    print("🎮 WELCOME TO CREATURE BATTLE ARENA! 🎮")
    print("="*50)
    
    # Create creatures (at least 2 instances of Creature class)
    charmander = Creature("Charmander", "Fire", 80, 20)
    squirtle = Creature("Squirtle", "Water", 85, 18)
    bulbasaur = Creature("Bulbasaur", "Grass", 90, 16)
    pikachu = Creature("Pikachu", "Electric", 75, 22)
    eevee = Creature("Eevee", "Normal", 80, 19)
    
    # Create trainers (at least 2 instances of Trainer class)
    ash = Trainer("Ash Ketchum", 10)
    gary = Trainer("Gary Oak", 10)
    brock = Trainer("Brock", 15)
    
    # Build trainer teams
    ash.add_creature(pikachu)
    ash.add_creature(charmander)
    ash.add_creature(bulbasaur)
    
    gary.add_creature(squirtle)
    gary.add_creature(eevee)
    
    brock.add_creature(charmander)
    brock.add_creature(eevee)
    brock.add_creature(bulbasaur)
    brock.add_creature(squirtle)
    
    # Test __repr__ methods
    print("\n📋 CREATURE REPRESENTATION:")
    print(charmander.__repr__())
    print(pikachu.__repr__())
    
    print("\n📋 TRAINER REPRESENTATION:")
    print(ash.__repr__())
    print(gary.__repr__())
    
    # Test individual methods
    print("\n🔧 TESTING METHODS:")
    print(ash.get_info())
    print(f"{pikachu.name} alive? {pikachu.is_alive()}")
    
    heal_amount = charmander.heal()
    print(f"Charmander healed {heal_amount} HP")
    
    # Test creature removal
    print("\n🗑️ TESTING REMOVE CREATURE:")
    ash.remove_creature("bulbasaur")
    print(ash.get_info())
    
    # Interactive battle
    print("\n" + "="*50)
    print("⚔️ LET'S BATTLE! ⚔️")
    print("="*50)
    
    while True:
        print("\nChoose an opponent:")
        print("1. Gary Oak")
        print("2. Brock")
        print("3. Quit")
        
        choice = input("Enter your choice (1-3): ")
        
        if choice == '1':
            battle(ash, gary)
        elif choice == '2':
            battle(ash, brock)
        elif choice == '3':
            print("Thanks for playing! 👋")
            break
        else:
            print("Invalid choice. Try again.")
        
        # Show trainer stats after battle
        print("\n📊 CURRENT STATS:")
        print(ash.get_info())
        print(gary.get_info())
        print(brock.get_info())
        
        # Option to heal team
        heal_choice = input("\nHeal your team before next battle? (yes/no): ").lower()
        if heal_choice == 'yes':
            for creature in ash.team:
                creature.hp = creature.max_hp
            print("Your team has been fully healed!")