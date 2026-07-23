from PIL import Image
import numpy as np

WIDTH = 30
HEIGHT = 30

#################################################
# READ SIGNED 32-BIT MEMORY FILE
#################################################

def read_signed_mem(filename):

    values = []

    with open(filename, "r") as f:

        for line in f:

            line = line.strip()

            if not line:
                continue

            value = int(line, 16)

            # Convert 32-bit unsigned hex to signed integer
            if value >= 0x80000000:
                value -= 0x100000000

            values.append(value)

    return np.array(values, dtype=np.int64)


#################################################
# READ SOBEL X AND SOBEL Y
#################################################

gx = read_signed_mem("output_x_30.mem")
gy = read_signed_mem("output_y_30.mem")

print("Sobel X pixels =", len(gx))
print("Sobel Y pixels =", len(gy))

#################################################
# CHECK SIZE
#################################################

if len(gx) != 900:
    raise ValueError(
        f"Sobel X should contain 900 pixels, but contains {len(gx)}"
    )

if len(gy) != 900:
    raise ValueError(
        f"Sobel Y should contain 900 pixels, but contains {len(gy)}"
    )

#################################################
# CALCULATE SOBEL MAGNITUDE
#
# G = sqrt(Gx^2 + Gy^2)
#################################################

magnitude = np.sqrt(
    gx.astype(np.float64)**2 +
    gy.astype(np.float64)**2
)

#################################################
# CLAMP TO 0 - 255
#################################################

magnitude = np.clip(magnitude, 0, 255)

#################################################
# CONVERT TO 8 BIT
#################################################

output = magnitude.astype(np.uint8)

#################################################
# RESHAPE INTO 30 x 30 IMAGE
#################################################

output = output.reshape(HEIGHT, WIDTH)

#################################################
# SAVE PNG
#################################################

img = Image.fromarray(output, mode="L")

img.save("sobel_final_riscv.png")

#################################################
# DEBUG
#################################################

print("--------------------------------")
print("SOBEL COMPLETE")
print("sobel_final.png generated")
print("--------------------------------")

print("Gx min =", gx.min())
print("Gx max =", gx.max())

print("Gy min =", gy.min())
print("Gy max =", gy.max())

print("Final min =", output.min())
print("Final max =", output.max())