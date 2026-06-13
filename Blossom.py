from linked_list import LinkedList, Node
from blossom_lib import flower_definitions

class HashMap:
    def __init__(self, size):
        self.array_size = size
        self.array = [LinkedList() for i in range(size)]
    
    def hash(self, key):
        """Calculate hash code by summing character values"""
        hash_code = 0
        for char in key.encode():
            hash_code += char
        return hash_code
    
    def compress(self, hash_code):
        """Compress hash code to array index"""
        return hash_code % self.array_size
    
    def assign(self, key, value):
        """Add or update a key-value pair"""
        array_index = self.compress(self.hash(key))
        list_at_array = self.array[array_index]
        
        # Check if key exists and update
        for item in list_at_array:
            if item[0] == key:
                item[1] = value
                return
        
        # If key doesn't exist, insert new node
        payload = Node([key, value])
        list_at_array.insert(payload)
    
    def retrieve(self, key):
        """Get value for a given key"""
        array_index = self.compress(self.hash(key))
        list_at_index = self.array[array_index]
        
        for item in list_at_index:
            if item[0] == key:
                return item[1]
        
        return None
    
    def remove(self, key):
        """Remove a key-value pair"""
        array_index = self.compress(self.hash(key))
        list_at_index = self.array[array_index]
        
        # Find and remove the node with this key
        current = list_at_index.get_head_node()
        previous = None
        
        while current:
            if current.get_value()[0] == key:
                if previous:
                    previous.set_next_node(current.get_next_node())
                else:
                    list_at_index.head_node = current.get_next_node()
                return True
            previous = current
            current = current.get_next_node()
        
        return False
    
    def get_all_keys(self):
        """Return all keys in the hash map"""
        keys = []
        for linked_list in self.array:
            for item in linked_list:
                keys.append(item[0])
        return keys
    
    def get_all_entries(self):
        """Return all key-value pairs"""
        entries = []
        for linked_list in self.array:
            for item in linked_list:
                entries.append(tuple(item))
        return entries


# Create and populate hash map
blossom = HashMap(len(flower_definitions))

for flower in flower_definitions:
    blossom.assign(flower[0], flower[1])

# Interactive flower meaning lookup
print("\n" + "🌸"*10)
print("BLOSSOM - The Language of Flowers")
print("🌸"*10)

print("\n📖 Available flowers:")
for key in blossom.get_all_keys():
    print(f"  • {key}")

while True:
    print("\n" + "-"*40)
    flower_name = input("🔍 Enter a flower name (or 'quit' to exit): ").lower().strip()
    
    if flower_name == 'quit':
        print("\n🌸 Goodbye! May flowers bring you joy! 🌸")
        break
    elif flower_name == 'list':
        print("\n📖 All flowers in database:")
        for key in blossom.get_all_keys():
            meaning = blossom.retrieve(key)
            print(f"  • {key}: {meaning}")
    elif flower_name == 'add':
        new_flower = input("Enter flower name: ").lower().strip()
        new_meaning = input("Enter its meaning: ").strip()
        blossom.assign(new_flower, new_meaning)
        print(f"✅ Added '{new_flower}': {new_meaning}")
    else:
        meaning = blossom.retrieve(flower_name)
        if meaning:
            print(f"\n💐 {flower_name.capitalize()}: {meaning}")
        else:
            print(f"\n❌ Sorry, '{flower_name}' is not in our database yet.")
            add_choice = input("Would you like to add it? (yes/no): ").lower()
            if add_choice == 'yes':
                new_meaning = input("Enter the meaning: ").strip()
                blossom.assign(flower_name, new_meaning)
                print(f"✅ Added '{flower_name}': {new_meaning}")