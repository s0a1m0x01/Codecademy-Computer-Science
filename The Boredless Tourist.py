# Alternative way to create attractions using list comprehension
destinations = ["Paris, France", "Shanghai, China", "Los Angeles, USA", "São Paulo, Brazil", "Cairo, Egypt"]
test_traveler = ['Erin Wilkes', 'Shanghai, China', ['historical site', 'art']]

def get_destination_index(destination):
    return destinations.index(destination)

def get_traveler_location(traveler):
    return get_destination_index(traveler[1])

# Create attractions with list comprehension
attractions = [[] for _ in range(len(destinations))]

def add_attraction(destination, attraction):
    try:
        attractions[get_destination_index(destination)].append(attraction)
    except ValueError:
        print(f"Destination '{destination}' not found!")

# Add all test attractions
add_attraction("Los Angeles, USA", ["Venice Beach", ["beach"]])
add_attraction("Paris, France", ["the Louvre", ["art", "museum"]])
add_attraction("Paris, France", ["Arc de Triomphe", ["historical site", "monument"]])
add_attraction("Shanghai, China", ["Yu Garden", ["garden", "historical site"]])
add_attraction("Shanghai, China", ["Yuz Museum", ["art", "museum"]])
add_attraction("Shanghai, China", ["Oriental Pearl Tower", ["skyscraper", "viewing deck"]])
add_attraction("Los Angeles, USA", ["LACMA", ["art", "museum"]])
add_attraction("São Paulo, Brazil", ["São Paulo Zoo", ["zoo"]])
add_attraction("São Paulo, Brazil", ["Pátio do Colégio", ["historical site"]])
add_attraction("Cairo, Egypt", ["Pyramids of Giza", ["monument", "historical site"]])
add_attraction("Cairo, Egypt", ["Egyptian Museum", ["museum"]])

def find_attractions(destination, interests):
    attractions_in_city = attractions[get_destination_index(destination)]
    return [attraction[0] for attraction in attractions_in_city 
            if any(interest in attraction[1] for interest in interests)]

def get_attractions_for_traveler(traveler):
    name, destination, interests = traveler
    matches = find_attractions(destination, interests)
    attractions_str = ", ".join(matches)
    return f"Hi {name}, we think you'll like these places around {destination}: {attractions_str}"

# Test the functions
print(get_destination_index("Los Angeles, USA"))  # 2
print(get_traveler_location(test_traveler))       # 1
print(find_attractions("Los Angeles, USA", ['art']))  # ['LACMA']
print(get_attractions_for_traveler(['Dereck Smill', 'Paris, France', ['monument']]))
# Output: Hi Dereck Smill, we think you'll like these places around Paris, France: Arc de Triomphe

git init
git add script.py
git commit -m "initial commit"
# After adding test objects
git add script.py
git commit -m "Added test objects"
# After adding destination logic
git add script.py
git commit -m "Added logic to find traveler destinations and convert to internal data"
# After adding attractions
git add script.py
git commit -m "Created attractions and functionality for adding new attractions"
# After adding interest finder
git add script.py
git commit -m "Added interest finder logic"
# After adding final function
git add script.py
git commit -m "Added function to generate message for traveler and present attractions they might be interested in."