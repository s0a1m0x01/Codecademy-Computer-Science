from stack import Stack
import time

# Create the stacks
stacks = []

left_stack = Stack("Left")
middle_stack = Stack("Middle")
right_stack = Stack("Right")

stacks.append(left_stack)
stacks.append(middle_stack)
stacks.append(right_stack)

# Set up the Game
print("\n" + "="*50)
print("🏰 TOWERS OF HANOI 🏰")
print("="*50)
print("\nRules:")
print("1. Only one disk can be moved at a time.")
print("2. Only the top disk can be moved.")
print("3. No disk may be placed on top of a smaller disk.\n")

num_disks = int(input("How many disks do you want to play with?\n"))

# Ensure at least 3 disks
while num_disks < 3:
    print("The game is more fun with at least 3 disks!")
    num_disks = int(input("Enter a number greater than or equal to 3\n"))

# Add disks to left_stack (largest at bottom, smallest on top)
for i in range(num_disks, 0, -1):
    left_stack.push(i)

# Calculate optimal number of moves
num_optimal_moves = 2 ** num_disks - 1
print(f"\nThe fastest you can solve this game is in {num_optimal_moves} moves")
print(f"Try to beat that! Good luck!\n")
time.sleep(1)

# Get User Input function
def get_input():
    choices = [stack.get_name()[0] for stack in stacks]
    
    while True:
        print("\n" + "-"*30)
        for i in range(len(stacks)):
            name = stacks[i].get_name()
            letter = choices[i]
            print(f"  Enter '{letter}' for {name}")
        print("-"*30)
        
        user_input = input("Your choice: ").upper()
        
        if user_input in choices:
            for i in range(len(stacks)):
                if user_input == choices[i]:
                    return stacks[i]
        else:
            print(f"Invalid choice! Please enter {', '.join(choices)}")

# Play the Game
num_user_moves = 0

# Game continues until right_stack has all disks
while right_stack.get_size() != num_disks:
    print("\n" + "="*50)
    print("Current Stacks:")
    print("="*50)
    for stack in stacks:
        stack.print_items()
    print("="*50)
    
    # Keep asking for valid move
    valid_move_made = False
    while not valid_move_made:
        print("\n📦 Choose source stack (move FROM):")
        from_stack = get_input()
        
        print("\n🎯 Choose destination stack (move TO):")
        to_stack = get_input()
        
        # Check if move is valid
        if from_stack.is_empty():
            print("\n❌ Invalid Move! That stack is empty. Try again.\n")
        elif not to_stack.is_empty() and from_stack.peek() > to_stack.peek():
            print(f"\n❌ Invalid Move! Disk {from_stack.peek()} is larger than disk {to_stack.peek()} on destination. Try again.\n")
        else:
            disk = from_stack.pop()
            to_stack.push(disk)
            num_user_moves += 1
            print(f"\n✅ Moved disk {disk} from {from_stack.get_name()} to {to_stack.get_name()}")
            valid_move_made = True
            time.sleep(0.5)

# Game completed
print("\n" + "="*50)
print("🏆 CONGRATULATIONS! 🏆")
print("="*50)
print(f"\nYou completed the game in {num_user_moves} moves!")
print(f"The optimal number of moves is {num_optimal_moves}")

if num_user_moves == num_optimal_moves:
    print("\n🎉 PERFECT! You solved it in the optimal number of moves! 🎉")
elif num_user_moves < num_optimal_moves:
    print("\n🤔 Wait... that's impossible! You found a better solution than optimal?!")
else:
    print(f"\nYou were {num_user_moves - num_optimal_moves} moves over the optimal solution.")
    print("Keep practicing to improve your score!")

print("\nThanks for playing Towers of Hanoi!\n")