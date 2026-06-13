letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
points = [1, 3, 3, 2, 1, 4, 2, 4, 1, 8, 5, 1, 3, 4, 1, 3, 10, 1, 1, 1, 1, 4, 4, 8, 4, 10]

# Build letter_to_points dictionary
letter_to_points = {letter: point for letter, point in zip(letters, points)}
letter_to_points[" "] = 0
letter_to_points.update({letter.lower(): point for letter, point in zip(letters, points)})  # Handle lowercase

# Score word function
def score_word(word):
    point_total = 0
    for letter in word:
        point_total += letter_to_points.get(letter, 0)
    return point_total

# Player data
player_to_words = {
    "wordNerd": ["BLUE", "TENNIS", "EXIT"],
    "Lexi Con": ["EARTH", "EYES", "MACHINE"],
    "Prof Reader": ["ERASER", "BELLY", "HUSKY"],
    "player1": ["ZAP", "COMA", "PERIOD"]
}

# Calculate points
player_to_points = {}
for player, words in player_to_words.items():
    player_points = 0
    for word in words:
        player_points += score_word(word)
    player_to_points[player] = player_points

# Display results
print("="*50)
print("SCRABBLE SCOREBOARD")
print("="*50)
print(f"{'Player':<15} {'Points':<10} {'Words'}")
print("-"*50)

for player, points in player_to_points.items():
    words = ", ".join(player_to_words[player])
    print(f"{player:<15} {points:<10} {words}")

# Determine winner
winner = max(player_to_points, key=player_to_points.get)
print("\n" + "="*50)
print(f"🏆 WINNER: {winner} with {player_to_points[winner]} points!")
print("="*50)

# Test brownie points
brownie_points = score_word("BROWNIE")
print(f"\nTest: 'BROWNIE' scores {brownie_points} points (should be 15)")