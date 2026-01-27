import matplotlib.pyplot as plt
import os
import sys

# Mandatory Font Setting
plt.rcParams['font.family'] = 'Noto Sans JP'

def save_diagram(fig, script_path):
    """
    Saves the figure as a PNG file with the same name as the script.
    Example: foo-diagram.py -> foo-diagram.png
    """
    base_name = os.path.splitext(os.path.basename(script_path))[0]
    output_path = f"{base_name}.png"
    fig.savefig(output_path)
    print(f"Diagram saved to: {output_path}")

def main():
    # Example usage:
    # fig, ax = plt.subplots()
    # ax.plot([1, 2, 3], [4, 5, 6])
    # ax.set_title("サンプル図 (Sample Diagram)")
    # save_diagram(fig, __file__)
    pass

if __name__ == "__main__":
    main()
