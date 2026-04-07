dog = {}
dog["name"] = "Bob"
dog["color"] = "Brown"
dog["Breed"] = "Pitbull"
dog["legs"] = 4
dog["age"] = 7

student= {
    "first_name" : "Kidus",
    "last_name" : "Yosef",
    "gender" : "Male",
    "age" : 17,
    "marital_status": False,
    "skills": ["Football",
                "Python"],
    "country": "South Africa",
    "city": "johannesburg",
    "address": "Upper Houghton"
    }

print(len(student))

student_value = student["skills"]
print(type(student_value))

student["skills"].extend(["Basketball", "Swimming"])
print("Updated skills:", student["skills"])

print(list(student.keys()))
print(list(student.values()))
print(list(student.items()))

del student["marital_status"]
print(student)

del dog
