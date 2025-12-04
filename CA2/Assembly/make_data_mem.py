def to_twos_complement_32(n):
    return n & 0xFFFFFFFF

data = [
    12, -5, 33, 7, 0, 19, -12, 44, 8, -1,
    3, 27, 15, 2, -8, 6, 9, -3, 25, 1
]

if len(data) != 20:
    raise ValueError("Array must contain exactly 20 elements.")

with open("data.mem", "w") as f:
    for n in data:
        hexval = f"{to_twos_complement_32(n):08x}"
        f.write(hexval + "\n")

print("data.mem generated successfully.")
