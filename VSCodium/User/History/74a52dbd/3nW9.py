item = input("What are you trying to buy? ")
price = float(input("What is the price? "))
quantity =  int(input("How many do you want? "))
total = price * quantity

print(f"Subtotal: ${total:.2f}")

receipt = input("Do you want a receipt with that? ")

if receipt.lower() == 'Yes' :
    print(f"You bought: {item} "
            f"x{quantity} "
            f"Your Total is: {total}$")
    print("Okay, Have a Nice Day!")
else :
    print("Okay, Have a Nice Day!")