program = []

#################################################
# Instruction encoders
#################################################

def addi(rd, rs1, imm):
    imm &= 0xFFF
    return (imm << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | 0x13

def add(rd, rs1, rs2):
    return (0 << 25) | (rs2 << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | 0x33

def mul(rd, rs1, rs2):
    return (1 << 25) | (rs2 << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | 0x33

def lb(rd, rs1, imm):
    imm &= 0xFFF
    return (imm << 20) | (rs1 << 15) | (0 << 12) | (rd << 7) | 0x03

def sw(rs2, rs1, imm):
    imm &= 0xFFF

    imm11_5 = (imm >> 5) & 0x7F
    imm4_0  = imm & 0x1F

    return (
        (imm11_5 << 25)
        | (rs2 << 20)
        | (rs1 << 15)
        | (2 << 12)
        | (imm4_0 << 7)
        | 0x23
    )

#################################################
# Sobel constants
#################################################

program.append(addi(20,0,-1))
program.append(addi(21,0,-2))
program.append(addi(22,0, 1))
program.append(addi(23,0, 2))

# Output pointer
program.append(addi(19,0,1984))

#################################################
# Generate convolution
#################################################

for row in range(30):
    for col in range(30):

        p0 = row*32 + col
        p1 = row*32 + col + 2

        p3 = (row+1)*32 + col
        p4 = (row+1)*32 + col + 2

        p6 = (row+2)*32 + col
        p7 = (row+2)*32 + col + 2

        #########################################
        # Loads
        #########################################

        program.append(lb(1,0,p0))
        program.append(lb(2,0,p1))

        program.append(lb(3,0,p3))
        program.append(lb(4,0,p4))

        program.append(lb(5,0,p6))
        program.append(lb(6,0,p7))

        #########################################
        # Multiply
        #########################################

        program.append(mul(7 ,1,20))
        program.append(mul(8 ,2,22))

        program.append(mul(9 ,3,21))
        program.append(mul(10,4,23))

        program.append(mul(11,5,20))
        program.append(mul(12,6,22))

        #########################################
        # Accumulate
        #########################################

        program.append(add(13,7,8))
        program.append(add(13,13,9))
        program.append(add(13,13,10))
        program.append(add(13,13,11))
        program.append(add(13,13,12))

        #########################################
        # Store result
        #########################################

       # Store Sobel result at address pointed to by x19
        program.append(sw(13,19,0))

# Move output pointer to next location
        program.append(addi(19,19,1))

#################################################
# Stop
#################################################

program.append(0x0000006F)

#################################################
# Write file
#################################################

with open("program.mem","w") as f:
    for inst in program:
        f.write(f"{inst:08x}\n")

print("Instructions =", len(program))
print("program.mem generated")
