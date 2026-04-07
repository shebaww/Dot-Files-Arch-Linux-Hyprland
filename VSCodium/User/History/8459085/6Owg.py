## MADE BY NAHOM NATNAEL Y12 BETA
dog = {}
dog["name"] = "Peanut"
dog["Breed"] = "Shiba Inu"
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


print(f"Length of Student Dictionary: {len(student)}")

student_value = student["skills"]
print(f"The data type of skills is: {type(student_value)}")

student["skills"].append("Might start C++")
print(f"Added skill is: Might start C++")

print(f"Keys: {list(student.keys())}")
print(f"Values: {list(student.values())}")
print(f"List of Tuples: {list(student.items())}")

del student["marital_status"]
del dog

print("Deleted dictionary 'dog' and student item 'marital_status'18")

assignment_grade = input("What do you think the grade will be out of 20?: ")

if (int(assignment_grade) < 20):
    input("Do you think you graded me correctly (yes or no answer)?: ")
    print("You graded wrongly try again")

else:
    print("You graded correctly have a great day!")