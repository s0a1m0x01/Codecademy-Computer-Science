from graph_search import bfs, dfs
from vc_metro import vc_metro
from vc_landmarks import vc_landmarks
from landmark_choices import landmark_choices

# Build your program below:

# Bonus Feature: Track multiple landmarks
landmark_string = ""
for letter, landmark in landmark_choices.items():
    landmark_string += f"{letter} - {landmark}\n"

# Stations under construction (can be updated by user)
stations_under_construction = []

def greet():
    print("\n" + "="*50)
    print("🚇 SKYROUTE - Vancouver Metro Routing Tool 🚇")
    print("="*50)
    print("\nHi there and welcome to SkyRoute!")
    print("We'll help you find the shortest route between Vancouver landmarks:\n")
    print(landmark_string)

def get_start():
    print("\n📍 ORIGIN")
    start_point_letter = input("Where are you coming from? Type in the corresponding letter: ").lower()
    if start_point_letter in landmark_choices:
        start_point = landmark_choices[start_point_letter]
        print(f"✅ Origin set to: {start_point}")
        return start_point
    else:
        print("❌ Sorry, that's not a landmark we have data on. Let's try this again...")
        return get_start()

def get_end():
    print("\n🎯 DESTINATION")
    end_point_letter = input("Where are you headed? Type in the corresponding letter: ").lower()
    if end_point_letter in landmark_choices:
        end_point = landmark_choices[end_point_letter]
        print(f"✅ Destination set to: {end_point}")
        return end_point
    else:
        print("❌ Sorry, that's not a landmark we have data on. Let's try this again...")
        return get_end()

def set_start_and_end(start_point, end_point):
    # Bonus: Handle same origin and destination
    if start_point == end_point and start_point is not None:
        print("\n⚠️ Your origin and destination are the same!")
        change = input("Would you like to change your destination? (y/n): ").lower()
        if change == 'y':
            end_point = get_end()
        else:
            print("No route needed - you're already there!")
            return start_point, end_point
    
    if start_point is not None:
        print(f"\nCurrent route: {start_point} → {end_point}")
        change_point = input("What would you like to change? Enter 'o' for origin, 'd' for destination, 'b' for both, or 'n' for no change: ").lower()
        
        if change_point == 'b':
            start_point = get_start()
            end_point = get_end()
        elif change_point == 'o':
            start_point = get_start()
        elif change_point == 'd':
            end_point = get_end()
        elif change_point == 'n':
            pass
        else:
            print("❌ Oops, that isn't 'o', 'd', 'b', or 'n'...")
            return set_start_and_end(start_point, end_point)
    else:
        start_point = get_start()
        end_point = get_end()
    
    return start_point, end_point

def get_route(start_point, end_point):
    # Bonus: Handle same landmark
    if start_point == end_point:
        return [start_point]
    
    start_stations = vc_landmarks[start_point]
    end_stations = vc_landmarks[end_point]
    routes = []
    
    for start_station in start_stations:
        for end_station in end_stations:
            metro_system = get_active_stations() if stations_under_construction else vc_metro
            
            if stations_under_construction:
                possible_route = dfs(metro_system, start_station, end_station)
                if not possible_route:
                    continue
            
            route = bfs(metro_system, start_station, end_station)
            if route:
                routes.append(route)
    
    if routes:
        shortest_route = min(routes, key=len)
        return shortest_route
    else:
        return None

def show_landmarks():
    see_landmarks = input("\nWould you like to see the list of landmarks again? Enter y/n: ").lower()
    if see_landmarks == 'y':
        print("\n" + landmark_string)

def get_active_stations():
    updated_metro = vc_metro.copy()
    
    for station_under_construction in stations_under_construction:
        for current_station, neighboring_stations in vc_metro.items():
            if current_station != station_under_construction:
                updated_metro[current_station] = neighboring_stations - set(stations_under_construction)
            else:
                updated_metro[current_station] = set([])
    
    return updated_metro

def update_construction_status():
    """Bonus: Allow users to update stations under construction"""
    print("\n🔧 METRO MAINTENANCE UPDATE 🔧")
    if stations_under_construction:
        print(f"Current stations under construction: {', '.join(stations_under_construction)}")
    else:
        print("No stations currently under construction.")
    
    update = input("\nWould you like to update the list? (y/n): ").lower()
    if update == 'y':
        print("\nEnter stations to add (comma-separated) or press Enter to skip:")
        to_add = input("Stations to add: ").strip()
        if to_add:
            new_stations = [s.strip() for s in to_add.split(',')]
            stations_under_construction.extend(new_stations)
        
        print("\nEnter stations to remove (comma-separated) or press Enter to skip:")
        to_remove = input("Stations to remove: ").strip()
        if to_remove:
            remove_stations = [s.strip() for s in to_remove.split(',')]
            for station in remove_stations:
                if station in stations_under_construction:
                    stations_under_construction.remove(station)
        
        print(f"\n✅ Updated stations under construction: {', '.join(stations_under_construction) if stations_under_construction else 'None'}")

def new_route(start_point=None, end_point=None):
    start_point, end_point = set_start_and_end(start_point, end_point)
    
    shortest_route = get_route(start_point, end_point)
    
    print("\n" + "-"*40)
    if shortest_route:
        if start_point == end_point:
            print("🏁 You're already at your destination!")
        else:
            print("🚆 ROUTE FOUND 🚆")
            print(f"\nFrom: {start_point}")
            print(f"To: {end_point}")
            print(f"\nNumber of stops: {len(shortest_route) - 1}")
            print("\nRoute:")
            for i, station in enumerate(shortest_route, 1):
                arrow = " → " if i < len(shortest_route) else ""
                print(f"  {i}. {station}{arrow}")
    else:
        print("❌ ROUTE NOT FOUND ❌")
        print(f"Unfortunately, there is currently no path between {start_point} and {end_point}.")
        if stations_under_construction:
            print(f"Affected stations: {', '.join(stations_under_construction)}")
    
    again = input("\nWould you like to see another route? Enter y/n: ").lower()
    if again == 'y':
        show_landmarks()
        # Bonus: Ask if user wants to update construction status
        update = input("\nWould you like to update station closures? (y/n): ").lower()
        if update == 'y':
            update_construction_status()
        new_route(start_point, end_point)

def goodbye():
    print("\n" + "="*50)
    print("Thanks for using SkyRoute! Safe travels! 🚇")
    print("="*50)

def skyroute():
    print("\n" + "🚇"*15)
    print("SKYROUTE - Metro Routing System")
    print("🚇"*15)
    greet()
    new_route()
    goodbye()

# Run the program
if __name__ == "__main__":
    skyroute()