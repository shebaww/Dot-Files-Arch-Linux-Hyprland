## MADE BY NAHOM NATNAEL Y12 BETA
dog = {}
dog["name"] = "Peanut"
dog["breed"] = "Shiba Inu"
dog["color"] = "Brown and White"
dog["legs"] = 4
dog["age"] = 3

student= {
    "first_name" : "Nahom",
    "last_name" : "Natnael",
    "gender" : "Male",
    "age" : 16,
    "skills": ["Python", "HTML", "CSS", "Javascript", "React", "Minimal SQL and Bash"],
    "country": "Ethiopia",
    "marital_status": False,
    "city": "Addis Ababa",
    "address": "Ayat"
    }


print(f"1. Length of Student Dictionary: {len(student)}")

student_value = student["skills"]
print(f"2. The data type of skills is: {type(student_value)}")

student["skills"].extend(["Might start C++", "Git"]) ## you could use .append too but append only allows for one addition i think, so i used .extend
print(f"3. Updated skill list: {student["skills"]}")

print(f"4. Keys: {list(student.keys())}")
print(f"5. Values: {list(student.values())}")
print(f"6. List of Tuples: {list(student.items())}")

del student["marital_status"]
del dog

print("7. Deleted dictionary 'dog' and student item 'marital_status'")

while True:
    assignment_grade = input("What do you think the grade will be out of 20?: ")

    try:
        assignment_grade = int(assignment_grade)
        if assignment_grade >= 20:
            print("You graded correctly! Have a great day!")
            break  # Exit the loop if the grade is 20 or more
        elif assignment_grade <= 10:
            print("LESS THAN 10? are you serious?")
            print("You graded wrongly, try again.")
        else:
            input("Do you think you graded me correctly (yes or no)?: ")
            print("You graded wrongly, try again.")
    except ValueError:
        print("Please enter a valid number.")
