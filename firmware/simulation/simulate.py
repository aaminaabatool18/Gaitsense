
# GaitSense - Day 1: Movement Simulation

# Artificial movement values for learning.
# These are NOT real MPU6050 measurements.

motion_samples = [
    0.12, 0.18, 0.15, 0.11,
    0.03, 0.02, 0.01, 0.02
]

window_size = 4

for i in range(0, len(motion_samples), window_size):

    window = motion_samples[i:i + window_size]

    average = sum(window) / len(window)

    print("Window:", i // window_size + 1)
    print("Average movement:", round(average, 3))

    if average < 0.05:
        print("TEST EVENT: Low movement detected")
    else:
        print("Normal test condition")

    print("--------------------")
