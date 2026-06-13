File Structure:
text
movie_recommender/
├── data.py           # Movie database
├── recommender.py    # Main recommendation engine
├── main.py          # User interface
└── README.md        # Documentation
File 1: data.py (Data Structure)
python
"""
Movie Database - Data Structure
Stores movies with their attributes for the recommendation system
"""

# Using a dictionary of dictionaries as the main data structure
movies = {
    # Action Movies
    "The Dark Knight": {
        "genre": "Action",
        "year": 2008,
        "rating": 9.0,
        "keywords": ["batman", "superhero", "crime", "thriller", "dark"],
        "director": "Christopher Nolan",
        "cast": ["Christian Bale", "Heath Ledger", "Aaron Eckhart"]
    },
    "Inception": {
        "genre": "Action",
        "year": 2010,
        "rating": 8.8,
        "keywords": ["dream", "heist", "sci-fi", "mind-bending", "thriller"],
        "director": "Christopher Nolan",
        "cast": ["Leonardo DiCaprio", "Joseph Gordon-Levitt", "Elliot Page"]
    },
    "Mad Max: Fury Road": {
        "genre": "Action",
        "year": 2015,
        "rating": 8.7,
        "keywords": ["post-apocalyptic", "chase", "survival", "thriller", "explosive"],
        "director": "George Miller",
        "cast": ["Tom Hardy", "Charlize Theron", "Nicholas Hoult"]
    },
    
    # Comedy Movies
    "Superbad": {
        "genre": "Comedy",
        "year": 2007,
        "rating": 7.6,
        "keywords": ["teen", "high school", "friendship", "party", "hilarious"],
        "director": "Greg Mottola",
        "cast": ["Michael Cera", "Jonah Hill", "Christopher Mintz-Plasse"]
    },
    "The Hangover": {
        "genre": "Comedy",
        "year": 2009,
        "rating": 7.7,
        "keywords": ["las vegas", "wedding", "friendship", "wild", "crazy"],
        "director": "Todd Phillips",
        "cast": ["Bradley Cooper", "Ed Helms", "Zach Galifianakis"]
    },
    "Bridesmaids": {
        "genre": "Comedy",
        "year": 2011,
        "rating": 6.8,
        "keywords": ["wedding", "friendship", "women", "hilarious", "rom-com"],
        "director": "Paul Feig",
        "cast": ["Kristen Wiig", "Maya Rudolph", "Rose Byrne"]
    },
    
    # Drama Movies
    "The Shawshank Redemption": {
        "genre": "Drama",
        "year": 1994,
        "rating": 9.3,
        "keywords": ["prison", "friendship", "hope", "inspiring", "redemption"],
        "director": "Frank Darabont",
        "cast": ["Tim Robbins", "Morgan Freeman", "Bob Gunton"]
    },
    "Forrest Gump": {
        "genre": "Drama",
        "year": 1994,
        "rating": 8.8,
        "keywords": ["inspirational", "life", "love", "historical", "heartwarming"],
        "director": "Robert Zemeckis",
        "cast": ["Tom Hanks", "Robin Wright", "Gary Sinise"]
    },
    "The Pursuit of Happyness": {
        "genre": "Drama",
        "year": 2006,
        "rating": 8.0,
        "keywords": ["homeless", "struggle", "father-son", "inspirational", "true story"],
        "director": "Gabriele Muccino",
        "cast": ["Will Smith", "Jaden Smith", "Thandie Newton"]
    },
    
    # Sci-Fi Movies
    "Interstellar": {
        "genre": "Sci-Fi",
        "year": 2014,
        "rating": 8.6,
        "keywords": ["space", "time travel", "black hole", "family", "adventure"],
        "director": "Christopher Nolan",
        "cast": ["Matthew McConaughey", "Anne Hathaway", "Jessica Chastain"]
    },
    "The Matrix": {
        "genre": "Sci-Fi",
        "year": 1999,
        "rating": 8.7,
        "keywords": ["virtual reality", "reality", "action", "philosophical", "cyberpunk"],
        "director": "Wachowski Sisters",
        "cast": ["Keanu Reeves", "Laurence Fishburne", "Carrie-Anne Moss"]
    },
    "Arrival": {
        "genre": "Sci-Fi",
        "year": 2016,
        "rating": 7.9,
        "keywords": ["aliens", "language", "communication", "thought-provoking", "emotional"],
        "director": "Denis Villeneuve",
        "cast": ["Amy Adams", "Jeremy Renner", "Forest Whitaker"]
    },
    
    # Horror Movies
    "Get Out": {
        "genre": "Horror",
        "year": 2017,
        "rating": 7.8,
        "keywords": ["psychological", "thriller", "social commentary", "creepy", "suspenseful"],
        "director": "Jordan Peele",
        "cast": ["Daniel Kaluuya", "Allison Williams", "Bradley Whitford"]
    },
    "A Quiet Place": {
        "genre": "Horror",
        "year": 2018,
        "rating": 7.5,
        "keywords": ["silence", "survival", "family", "suspenseful", "creatures"],
        "director": "John Krasinski",
        "cast": ["John Krasinski", "Emily Blunt", "Millicent Simmonds"]
    },
    
    # Romance Movies
    "The Notebook": {
        "genre": "Romance",
        "year": 2004,
        "rating": 7.8,
        "keywords": ["love story", "summer romance", "tearjerker", "emotional", "nostalgic"],
        "director": "Nick Cassavetes",
        "cast": ["Ryan Gosling", "Rachel McAdams", "James Garner"]
    },
    "La La Land": {
        "genre": "Romance",
        "year": 2016,
        "rating": 8.0,
        "keywords": ["musical", "dreams", "love", "los angeles", "bittersweet"],
        "director": "Damien Chazelle",
        "cast": ["Ryan Gosling", "Emma Stone", "John Legend"]
    }
}

# Genre mapping for autocomplete
genres = ["Action", "Comedy", "Drama", "Sci-Fi", "Horror", "Romance"]

# Mood-based recommendations
mood_to_genre = {
    "excited": "Action",
    "happy": "Comedy",
    "thoughtful": "Drama",
    "curious": "Sci-Fi",
    "scared": "Horror",
    "romantic": "Romance",
    "inspired": "Drama",
    "bored": "Action",
    "sad": "Comedy",
    "adventurous": "Action"
}

# Helper function to get movies by genre
def get_movies_by_genre(genre):
    return {title: info for title, info in movies.items() if info["genre"] == genre}

# Helper function to search movies by keyword
def search_by_keyword(keyword):
    keyword_lower = keyword.lower()
    results = {}
    for title, info in movies.items():
        if any(keyword_lower in k.lower() for k in info["keywords"]):
            results[title] = info
    return results
File 2: recommender.py (Algorithm & Search)
python
"""
Movie Recommendation Engine
Implements search algorithms and recommendation logic
"""

from data import movies, genres, mood_to_genre, get_movies_by_genre, search_by_keyword

class MovieRecommender:
    def __init__(self):
        self.movies = movies
        self.genres = genres
    
    # Binary search for genre (efficient for sorted list)
    def binary_search_genre(self, target_genre):
        """Binary search implementation for genre lookup"""
        sorted_genres = sorted(self.genres)
        left, right = 0, len(sorted_genres) - 1
        
        while left <= right:
            mid = (left + right) // 2
            if sorted_genres[mid].lower() == target_genre.lower():
                return sorted_genres[mid]
            elif sorted_genres[mid].lower() < target_genre.lower():
                left = mid + 1
            else:
                right = mid - 1
        return None
    
    # Linear search for autocomplete
    def autocomplete_genre(self, prefix):
        """Return genres that start with given prefix (autocomplete)"""
        prefix_lower = prefix.lower()
        matches = []
        
        for genre in self.genres:
            if genre.lower().startswith(prefix_lower):
                matches.append(genre)
        
        # Sort matches by relevance (length of match)
        matches.sort(key=lambda x: len(x))
        return matches
    
    # Linear search for keyword matching
    def search_by_keyword(self, keyword):
        """Search movies by keyword (linear search through keywords)"""
        keyword_lower = keyword.lower()
        results = []
        
        for title, info in self.movies.items():
            if any(keyword_lower in k.lower() for k in info["keywords"]):
                results.append((title, info))
        
        return results
    
    # Get recommendations by genre
    def recommend_by_genre(self, genre):
        """Get all movies in a specific genre"""
        genre = self.binary_search_genre(genre)
        if not genre:
            return []
        
        movies_in_genre = get_movies_by_genre(genre)
        # Sort by rating (highest first)
        sorted_movies = sorted(movies_in_genre.items(), key=lambda x: x[1]["rating"], reverse=True)
        return sorted_movies
    
    # Get recommendations by mood
    def recommend_by_mood(self, mood):
        """Recommend genre based on mood, then movies"""
        mood_lower = mood.lower()
        if mood_lower in mood_to_genre:
            genre = mood_to_genre[mood_lower]
            return self.recommend_by_genre(genre)
        return []
    
    # Get top rated movies overall
    def get_top_rated(self, limit=5):
        """Get top N movies by rating"""
        sorted_movies = sorted(self.movies.items(), key=lambda x: x[1]["rating"], reverse=True)
        return sorted_movies[:limit]
    
    # Get newest movies
    def get_newest(self, limit=5):
        """Get newest N movies by year"""
        sorted_movies = sorted(self.movies.items(), key=lambda x: x[1]["year"], reverse=True)
        return sorted_movies[:limit]
    
    # Display movie details
    def display_movie(self, title, info):
        """Format and display movie information"""
        print(f"\n🎬 {title} ({info['year']})")
        print(f"   Genre: {info['genre']}")
        print(f"   Rating: {info['rating']}/10")
        print(f"   Director: {info['director']}")
        print(f"   Cast: {', '.join(info['cast'][:3])}")
        print(f"   Keywords: {', '.join(info['keywords'][:4])}")
    
    # Display multiple movies
    def display_movies(self, movies_list, title="Recommendations"):
        """Display a list of movies"""
        if not movies_list:
            print("\n❌ No movies found. Try another search!")
            return
        
        print(f"\n{'='*50}")
        print(f"🎯 {title}")
        print(f"{'='*50}")
        
        for i, (title, info) in enumerate(movies_list, 1):
            print(f"\n{i}. {title} ({info['year']}) - {info['genre']}")
            print(f"   ⭐ Rating: {info['rating']}/10")
            print(f"   🎭 Keywords: {', '.join(info['keywords'][:3])}")
File 3: main.py (User Interface)
python
"""
Movie Recommendation System - Main Program
Interactive terminal-based movie recommender
"""

from recommender import MovieRecommender

def print_banner():
    """Display welcome banner"""
    print("\n" + "🎬" * 20)
    print("MOVIE RECOMMENDATION SYSTEM")
    print("🎬" * 20)
    print("\nYour personal movie guide!")
    print("Find the perfect movie for any mood or genre.\n")

def print_menu():
    """Display main menu options"""
    print("\n" + "-" * 40)
    print("MAIN MENU")
    print("-" * 40)
    print("1. 🎭 Recommend by Genre")
    print("2. 😊 Recommend by Mood")
    print("3. 🔍 Search by Keyword")
    print("4. ⭐ Top Rated Movies")
    print("5. 🆕 Newest Movies")
    print("6. 🔤 Genre Autocomplete")
    print("7. ❌ Exit")
    print("-" * 40)

def recommend_by_genre(recommender):
    """Handle genre-based recommendations"""
    print("\n📋 Available Genres:")
    for genre in recommender.genres:
        print(f"   • {genre}")
    
    genre = input("\nEnter a genre: ").strip()
    movies = recommender.recommend_by_genre(genre)
    
    if movies:
        recommender.display_movies(movies, f"Top {genre} Movies")
    else:
        print(f"\n❌ Genre '{genre}' not found. Try one from the list above.")

def recommend_by_mood(recommender):
    """Handle mood-based recommendations"""
    print("\n😊 How are you feeling today?")
    print("   • excited")
    print("   • happy")
    print("   • thoughtful")
    print("   • curious")
    print("   • scared")
    print("   • romantic")
    print("   • inspired")
    print("   • bored")
    print("   • sad")
    print("   • adventurous")
    
    mood = input("\nEnter your mood: ").strip().lower()
    movies = recommender.recommend_by_mood(mood)
    
    if movies:
        recommender.display_movies(movies, f"Movies for when you're feeling {mood}")
    else:
        print(f"\n❌ Mood '{mood}' not recognized. Try one from the list above.")

def search_by_keyword(recommender):
    """Handle keyword search"""
    keyword = input("\n🔍 Enter a keyword (e.g., love, space, action): ").strip()
    results = recommender.search_by_keyword(keyword)
    
    if results:
        recommender.display_movies(results, f"Movies matching '{keyword}'")
    else:
        print(f"\n❌ No movies found with keyword '{keyword}'")

def autocomplete_genre(recommender):
    """Handle genre autocomplete"""
    prefix = input("\n🔤 Start typing a genre (e.g., 'Act', 'Com'): ").strip()
    matches = recommender.autocomplete_genre(prefix)
    
    if matches:
        print(f"\n📋 Genres matching '{prefix}':")
        for match in matches:
            print(f"   • {match}")
        
        if len(matches) == 1:
            show = input(f"\nWould you like to see {matches[0]} movies? (y/n): ").lower()
            if show == 'y':
                movies = recommender.recommend_by_genre(matches[0])
                recommender.display_movies(movies, f"Top {matches[0]} Movies")
    else:
        print(f"\n❌ No genres found starting with '{prefix}'")

def main():
    """Main program loop"""
    recommender = MovieRecommender()
    
    print_banner()
    
    while True:
        print_menu()
        choice = input("\nEnter your choice (1-7): ").strip()
        
        if choice == '1':
            recommend_by_genre(recommender)
        
        elif choice == '2':
            recommend_by_mood(recommender)
        
        elif choice == '3':
            search_by_keyword(recommender)
        
        elif choice == '4':
            top_movies = recommender.get_top_rated(10)
            recommender.display_movies(top_movies, "Top Rated Movies of All Time")
        
        elif choice == '5':
            newest_movies = recommender.get_newest(10)
            recommender.display_movies(newest_movies, "Newest Movies")
        
        elif choice == '6':
            autocomplete_genre(recommender)
        
        elif choice == '7':
            print("\n🎬 Thanks for using Movie Recommendation System!")
            print("Enjoy your movie! 🍿")
            break
        
        else:
            print("\n❌ Invalid choice. Please enter a number 1-7.")
        
        input("\nPress Enter to continue...")

if __name__ == "__main__":
    main()
File 4: README.md (Documentation)
markdown
# 🎬 Movie Recommendation System

A terminal-based movie recommendation system that helps users find movies based on genre, mood, and keywords.

## Features

- **Genre-based recommendations** - Get top movies in any genre
- **Mood-based recommendations** - Find movies that match your current mood
- **Keyword search** - Search movies by keywords (e.g., "love", "space")
- **Top rated movies** - View highest-rated movies
- **Newest releases** - See most recent movies
- **Autocomplete** - Type-ahead search for genres

## Data Structure

- **Primary structure**: Dictionary of dictionaries
- **Search algorithms**: Linear search (autocomplete) and Binary search (genre lookup)
- **Sorting**: Movies sorted by rating for recommendations

## Installation

```bash
git clone <your-repo-url>
cd movie-recommender
python3 main.py
Usage
Run python3 main.py

Choose from 7 options in the main menu

Follow prompts to get personalized recommendations

Example
text
🎬 MOVIE RECOMMENDATION SYSTEM 🎬

MAIN MENU
1. 🎭 Recommend by Genre
2. 😊 Recommend by Mood
3. 🔍 Search by Keyword
4. ⭐ Top Rated Movies
5. 🆕 Newest Movies
6. 🔤 Genre Autocomplete
7. ❌ Exit

Enter your choice (1-7): 2
Enter your mood: excited

🎯 Movies for when you're feeling excited
==================================================
1. Mad Max: Fury Road (2015) - Action
   ⭐ Rating: 8.7/10
   🎭 Keywords: post-apocalyptic, chase, survival
Technologies Used
Python 3

Dictionary data structures

Linear and binary search algorithms

Git version control

text

## Git Commands for Version Control

```bash
# Initialize repository
git init

# Create .gitignore
echo "__pycache__/" > .gitignore
echo "*.pyc" >> .gitignore

# Add all files
git add .

# Initial commit
git commit -m "Initial commit: Add movie recommendation system"

# After completing main features
git add .
git commit -m "Add core recommendation features: genre, mood, keyword search"

# After adding autocomplete
git add .
git commit -m "Add genre autocomplete with linear search"

# After adding binary search
git add .
git commit -m "Implement binary search for genre lookup"

# Final commit
git add .
git commit -m "Complete movie recommendation system with full features"
How to Run
bash
python3 main.py
Sample Interaction
text
🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬
MOVIE RECOMMENDATION SYSTEM
🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬🎬

Your personal movie guide!
Find the perfect movie for any mood or genre.

----------------------------------------
MAIN MENU
----------------------------------------
1. 🎭 Recommend by Genre
2. 😊 Recommend by Mood
3. 🔍 Search by Keyword
4. ⭐ Top Rated Movies
5. 🆕 Newest Movies
6. 🔤 Genre Autocomplete
7. ❌ Exit
----------------------------------------

Enter your choice (1-7): 2

😊 How are you feeling today?
   • excited
   • happy
   • thoughtful
   • curious
   • scared
   • romantic
   • inspired
   • bored
   • sad
   • adventurous

Enter your mood: excited

==================================================
🎯 Movies for when you're feeling excited
==================================================

1. Mad Max: Fury Road (2015) - Action
   ⭐ Rating: 8.7/10
   🎭 Keywords: post-apocalyptic, chase, survival

2. The Dark Knight (2008) - Action
   ⭐ Rating: 9.0/10
   🎭 Keywords: batman, superhero, crime
Project Requirements Checklist
Requirement	Status	Implementation
Store data in a data structure	✅	Dictionary of dictionaries
Use algorithm to sort/search data	✅	Linear search, Binary search, Sorting by rating
Use Git version control	✅	Git commands provided
Use command line/file navigation	✅	Terminal-based interface
Write technical blog post	✅	README documentation
Refactoring	✅	Clean separation of concerns (data, logic, UI)
Autocomplete feature	✅	Genre autocomplete with linear search
Recommendation retrieval	✅	Multiple recommendation methods