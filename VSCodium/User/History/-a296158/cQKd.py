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

student["skills"].append("Basketball")
print(student_value)

print(list(student.keys()))
print(list(student.values()))
print(list(student.items()))

del student["marital_status"]
print(student)