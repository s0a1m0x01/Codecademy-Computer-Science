import csv
import json

# Task 1 & 2: Create a list for compromised users
compromised_users = []

# Task 3: Open the passwords.csv file
with open('passwords.csv') as password_file:
    # Task 4: Create CSV reader object
    password_csv = csv.DictReader(password_file)
    
    # Task 5 & 6: Iterate through rows and collect usernames
    for password_row in password_csv:
        # Task 6 (commented out): print(password_row['Username'])
        # Task 7: Add username to compromised_users list
        compromised_users.append(password_row['Username'])

# Task 8: Write compromised users to a text file
with open('compromised_users.txt', 'w') as compromised_user_file:
    # Task 9 & 10: Write each username to the file
    for user in compromised_users:
        compromised_user_file.write(user + '\n')

# Task 11: Create boss message JSON file
with open('boss_message.json', 'w') as boss_message:
    # Task 12: Create dictionary with boss message
    boss_message_dict = {
        "recipient": "The Boss",
        "message": "Mission Success"
    }
    # Task 13: Write dictionary to JSON file
    json.dump(boss_message_dict, boss_message)

# Task 14: Open new_passwords.csv for writing
with open('new_passwords.csv', 'w') as new_passwords_obj:
    # Task 15: Slash Null signature
    slash_null_sig = """
 _  _     ___   __  ____             
/ )( \   / __) /  \(_  _)            
) \/ (  ( (_ \(  O ) )(              
\____/   \___/ \__/ (__)             
 _  _   __    ___  __ _  ____  ____  
/ )( \ / _\  / __)(  / )(  __)(    \ 
) __ (/    \( (__  )  (  ) _)  ) D ( 
\_)(_/\_/\_/ \___)(__\_)(____)(____/ 
        ____  __     __   ____  _  _ 
 ___   / ___)(  )   / _\ / ___)/ )( \
(___)  \___ \/ (_/\/    \\___ \) __ (
       (____/\____/\_/\_/(____/\_)(_/
 __ _  _  _  __    __                
(  ( \/ )( \(  )  (  )               
/    /) \/ (/ (_/\/ (_/\             
\_)__)\____/\____/\____/
"""
    # Task 16: Write signature to file
    new_passwords_obj.write(slash_null_sig)

print("Mission complete! Files have been processed.")
print(f"Found {len(compromised_users)} compromised users.")