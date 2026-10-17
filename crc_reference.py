value = int("123456789ABCDEF12345", 16)
crc = 0

for i in range(81, -1, -1):
    feedback = ((crc >> 14) & 1) ^ ((value >> i) & 1)
    crc = (crc << 1) & 0x7FFF

    if feedback:
        crc ^= 0x4599

print(f"Reference CRC-15 = {crc:04X}")
