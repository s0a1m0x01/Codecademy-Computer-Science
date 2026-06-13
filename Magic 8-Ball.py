import random

# Setting up the asker and question
name = "Joe"  # Change this to your name, or leave as "" for testing
question = "Will I win the lottery?"  # Change this to any yes/no question
answer = ""

# Generate random number between 1 and 9
random_number = random.randint(1, 9)

# Control flow for Magic 8-Ball answers
if random_number == 1:
    answer = "Yes - definitely"
elif random_number == 2:
    answer = "It is decidedly so"
elif random_number == 3:
    answer = "Without a doubt"
elif random_number == 4:
    answer = "Reply hazy, try again"
elif random_number == 5:
    answer = "Ask again later"
elif random_number == 6:
    answer = "Better not tell you now"
elif random_number == 7:
    answer = "My sources say no"
elif random_number == 8:
    answer = "Outlook not so good"
elif random_number == 9:
    answer = "Very doubtful"
else:
    answer = "Error"

# Seeing the result
if name == "" and question == "":
    print("You must ask a question!")
elif question == "":
    print("The Magic 8-Ball cannot provide a fortune without a question.")
elif name == "":
    print(f"Question: {question}")
    print(f"Magic 8-Ball's answer: {answer}")
else:
    print(f"{name} asks: {question}")
    print(f"Magic 8-Ball's answer: {answer}")