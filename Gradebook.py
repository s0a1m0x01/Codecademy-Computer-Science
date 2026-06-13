# Task 1: Create subjects list
subjects = ["physics", "calculus", "poetry", "history"]

# Task 2: Create grades list
grades = [98, 97, 85, 88]

# Task 3: Create 2D list combining subjects and grades
gradebook = [
    ["physics", 98],
    ["calculus", 97],
    ["poetry", 85],
    ["history", 88]
]

# Task 4: Print gradebook
print("Initial gradebook:")
print(gradebook)

# Task 5: Add computer science with grade 100
gradebook.append(["computer science", 100])

# Task 6: Add visual arts with grade 93
gradebook.append(["visual arts", 93])

print("\nAfter adding new subjects:")
print(gradebook)

# Task 7: Add 5 points to visual arts grade
gradebook[-1][1] += 5  # Last sublist, second element (grade)
# Alternative: gradebook[5][1] += 5

print("\nAfter adding 5 points to visual arts:")
print(gradebook)

# Task 8: Remove numerical grade for poetry class
# Find poetry class and remove its grade (the 85)
for subject in gradebook:
    if subject[0] == "poetry":
        subject.remove(85)
        break

print("\nAfter removing poetry grade:")
print(gradebook)

# Task 9: Add "Pass" to poetry class
for subject in gradebook:
    if subject[0] == "poetry":
        subject.append("Pass")
        break

print("\nAfter adding 'Pass' to poetry:")
print(gradebook)

# Task 10: Combine with last_semester_gradebook
# This is provided by the project
last_semester_gradebook = [["politics", 80], ["latin", 96], ["dance", 97], ["architecture", 65]]

full_gradebook = last_semester_gradebook + gradebook

print("\nFull gradebook (last semester + this semester):")
print(full_gradebook)