import random
from graph import Graph, build_tsp_graph

# Enhanced Vertex.py with additional methods
class Vertex:
    def __init__(self, value):
        self.value = value
        self.edges = {}
    
    def add_edge(self, vertex, weight=0):
        self.edges[vertex] = weight
    
    def get_edges(self):
        return self.edges.keys()
    
    def get_edge_weight(self, edge):
        return self.edges.get(edge, float('inf'))
    
    def get_edge_weights(self):
        return self.edges

# Enhanced Graph.py with additional methods
class Graph:
    def __init__(self):
        self.vertices = {}
    
    def add_vertex(self, value):
        if value not in self.vertices:
            self.vertices[value] = Vertex(value)
            return True
        return False
    
    def add_edge(self, vertex1, vertex2, weight=0):
        if vertex1 in self.vertices and vertex2 in self.vertices:
            self.vertices[vertex1].add_edge(self.vertices[vertex2], weight)
            self.vertices[vertex2].add_edge(self.vertices[vertex1], weight)
            return True
        return False
    
    def get_vertices(self):
        return self.vertices.keys()
    
    def get_vertex(self, value):
        return self.vertices.get(value)

def build_tsp_graph():
    g = Graph()
    
    # Add cities
    cities = ["New York", "Boston", "Philadelphia", "Washington DC", "Baltimore"]
    for city in cities:
        g.add_vertex(city)
    
    # Add distances (in miles)
    edges = [
        ("New York", "Boston", 215),
        ("New York", "Philadelphia", 95),
        ("New York", "Washington DC", 225),
        ("New York", "Baltimore", 190),
        ("Boston", "Philadelphia", 310),
        ("Boston", "Washington DC", 440),
        ("Boston", "Baltimore", 405),
        ("Philadelphia", "Washington DC", 140),
        ("Philadelphia", "Baltimore", 100),
        ("Washington DC", "Baltimore", 40)
    ]
    
    for edge in edges:
        g.add_edge(edge[0], edge[1], edge[2])
    
    return g

def all_vertices_visited(visited_status):
    return all(status == "visited" for status in visited_status.values())

def calculate_path_distance(graph, path_list):
    """Calculate total distance of a path"""
    total_distance = 0
    for i in range(len(path_list) - 1):
        current_vertex = graph.get_vertex(path_list[i])
        next_vertex = graph.get_vertex(path_list[i + 1])
        if next_vertex in current_vertex.get_edge_weights():
            total_distance += current_vertex.get_edge_weight(next_vertex)
    return total_distance

def traveling_salesperson(graph, start_city=None):
    # Initialize visited status
    visited_status = {vertex: "unvisited" for vertex in graph.get_vertices()}
    
    # Select starting vertex
    all_vertices = list(graph.get_vertices())
    if start_city and start_city in all_vertices:
        current_vertex_value = start_city
    else:
        current_vertex_value = random.choice(all_vertices)
    
    current_vertex = graph.get_vertex(current_vertex_value)
    visited_status[current_vertex_value] = "visited"
    path = [current_vertex_value]
    
    visited_all = all_vertices_visited(visited_status)
    
    print(f"\n📍 Starting at: {current_vertex_value}")
    
    while not visited_all:
        # Get available edges from current vertex
        available_edges = {}
        for edge, weight in current_vertex.get_edge_weights().items():
            if visited_status[edge.value] == "unvisited":
                available_edges[edge] = weight
        
        if not available_edges:
            # No unvisited neighbors - must end here
            break
        
        # Greedy choice: pick closest unvisited vertex
        next_vertex = min(available_edges, key=available_edges.get)
        next_vertex_value = next_vertex.value
        edge_weight = available_edges[next_vertex]
        
        # Move to next vertex
        current_vertex = next_vertex
        current_vertex_value = next_vertex_value
        visited_status[current_vertex_value] = "visited"
        path.append(current_vertex_value)
        
        print(f"  → {current_vertex_value} (+{edge_weight} miles)")
        
        visited_all = all_vertices_visited(visited_status)
    
    # Calculate total distance
    total_distance = calculate_path_distance(graph, path)
    
    # Display results
    print("\n" + "="*50)
    print("TRAVELING SALESPERSON SOLUTION")
    print("="*50)
    print(f"Route: {' → '.join(path)}")
    print(f"Total distance: {total_distance} miles")
    print(f"Number of cities visited: {len(path)}")
    print("="*50)
    
    return path, total_distance

def run_multiple_trials(graph, trials=10):
    """Run multiple trials to find the best route"""
    print(f"\n🔄 Running {trials} trials to find optimal route...")
    
    best_path = None
    best_distance = float('inf')
    
    for i in range(trials):
        print(f"\nTrial {i+1}:")
        path, distance = traveling_salesperson(graph)
        if distance < best_distance:
            best_distance = distance
            best_path = path
    
    print("\n" + "🏆"*15)
    print("BEST ROUTE FOUND")
    print("🏆"*15)
    print(f"Route: {' → '.join(best_path)}")
    print(f"Total distance: {best_distance} miles")
    print("🏆"*15)
    
    return best_path, best_distance

if __name__ == "__main__":
    print("\n" + "🌍"*15)
    print("TRAVELING SALESPERSON PROBLEM")
    print("🌍"*15)
    print("\nA greedy algorithm to find a short route visiting all cities.")
    
    tsp_graph = build_tsp_graph()
    
    # Single run
    traveling_salesperson(tsp_graph)
    
    # Optional: Run multiple trials to find best route
    print("\n" + "-"*50)
    print("Would you like to run multiple trials to find the best route?")
    response = input("Enter number of trials (or press Enter to skip): ").strip()
    if response.isdigit():
        run_multiple_trials(tsp_graph, int(response))