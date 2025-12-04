def to_twos_complement_32(n):
    return n & 0xFFFFFFFF


INPUT_FILE = "Assembly/array_of_integers.txt"
OUTPUT_FILE = "data.mem"


def read_numbers(path):
    numbers = []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            numbers.append(int(line))
    return numbers


def write_data_mem(numbers, path):
    with open(path, "w") as f:
        for n in numbers:
            hexval = f"{to_twos_complement_32(n):08x}"
            f.write(hexval + "\n")
    print(f"{path} generated successfully with {len(numbers)} entries.")


def main():
    nums = read_numbers(INPUT_FILE)
    write_data_mem(nums, OUTPUT_FILE)


if __name__ == "__main__":
    main()
