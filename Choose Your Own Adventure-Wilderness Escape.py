######
# TREENODE CLASS
######

class TreeNode:
    def __init__(self, story_piece):
        self.story_piece = story_piece
        self.choices = []
    
    def add_child(self, node):
        self.choices.append(node)
    
    def traverse(self):
        story_node = self
        print("\n" + "📖 " + story_node.story_piece + " 📖")
        
        while story_node.choices:
            print("\n" + "-"*40)
            choice = input("🎮 Enter 1 or 2 to continue (or 'q' to quit): ")
            
            if choice.lower() == 'q':
                print("\n👋 Thanks for playing! Goodbye!")
                return
            
            if choice not in ['1', '2']:
                print("\n❌ Invalid choice! Please enter 1 or 2.")
            else:
                chosen_index = int(choice) - 1
                chosen_child = story_node.choices[chosen_index]
                print("\n✨ " + chosen_child.story_piece + " ✨")
                story_node = chosen_child
        
        print("\n🏁 Your adventure has ended. 🏁")
    
    def get_story_summary(self):
        """Return a summary of the story tree"""
        summary = [self.story_piece[:50] + "..."]
        for child in self.choices:
            summary.append(f"  - {child.story_piece[:50]}...")
        return "\n".join(summary)

######
# VARIABLES FOR TREE
######

# Story root (beginning)
story_root = TreeNode("""
🌲 You are in a forest clearing. There is a path to the left.
🐻 A bear emerges from the trees and roars!
Do you: 
1️⃣ Roar back!
2️⃣ Run to the left...
""")

# Choice A: Roar back
choice_a = TreeNode("""
🐻 The bear is startled and runs away.
Do you:
1️⃣ Shout 'Sorry bear!'
2️⃣ Yell 'Hooray!'
""")

# Choice B: Run to the left
choice_b = TreeNode("""
🌻 You come across a clearing full of flowers. 
🐻 The bear follows you and asks 'what gives?'
Do you:
1️⃣ Gasp 'A talking bear!'
2️⃣ Explain that the bear scared you.
""")

# Add choices to story_root
story_root.add_child(choice_a)
story_root.add_child(choice_b)

# Choice A branches (after roaring back)
choice_a_1 = TreeNode("""
🐻 The bear returns and tells you it's been a rough week. 
After making peace with a talking bear, he shows you the way out of the forest.

🎉 YOU HAVE ESCAPED THE WILDERNESS! 🎉
""")

choice_a_2 = TreeNode("""
🐻 The bear returns and tells you that bullying is not okay 
before leaving you alone in the wilderness.

😢 YOU REMAIN LOST. 😢
""")

# Add branches to choice_a
choice_a.add_child(choice_a_1)
choice_a.add_child(choice_a_2)

# Choice B branches (after running left)
choice_b_1 = TreeNode("""
🐻 The bear is unamused. After smelling the flowers, 
it turns around and leaves you alone.

😢 YOU REMAIN LOST. 😢
""")

choice_b_2 = TreeNode("""
🐻 The bear understands and apologizes for startling you. 
Your new friend shows you a path leading out of the forest.

🎉 YOU HAVE ESCAPED THE WILDERNESS! 🎉
""")

# Add branches to choice_b
choice_b.add_child(choice_b_1)
choice_b.add_child(choice_b_2)

######
# TESTING AREA
######

def show_menu():
    print("\n" + "🌸"*10)
    print("WILDERNESS ESCAPE")
    print("🌸"*10)
    print("\nA Choose-Your-Own-Adventure Game")
    print("\nHow to play:")
    print("• Type '1' for the first option")
    print("• Type '2' for the second option")
    print("• Type 'q' to quit at any time")
    print("\n" + "="*50)

# Game introduction
show_menu()

input("\nPress Enter to begin your adventure...\n")

print("Once upon a time...")
print("\n" + "="*50)

# Start the adventure
story_root.traverse()

print("\n" + "="*50)
print("Thanks for playing Wilderness Escape!")
print("Come back soon for more adventures!")
print("="*50)