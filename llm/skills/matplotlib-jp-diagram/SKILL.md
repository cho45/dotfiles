---
name: matplotlib-jp-diagram
description: "Generates Python scripts using matplotlib for data visualization with Japanese font support (Noto Sans JP) and specific naming conventions. Use when requested to create diagrams, charts, or plots that require Japanese text or follow a specific filename pattern (foo-diagram.py -> foo-diagram.png)."
---

# matplotlib-jp-diagram

This skill provides a standard way to generate matplotlib diagrams with Japanese font support and consistent output naming.

## Guidelines

1. **Mandatory Font Configuration**: Always include the following line before plotting:
   ```python
   import matplotlib.pyplot as plt
   plt.rcParams['font.family'] = 'Noto Sans JP'
   ```

2. **File Naming Convention**:
   - The Python script should be named with a suffix like `-diagram.py` (e.g., `performance-diagram.py`).
   - The output image must be a PNG file with the exact same base name (e.g., `performance-diagram.png`).

3. **Output Logic**:
   Ensure the script automatically saves the diagram to the correct PNG path when executed.

   ```python
   import os
   output_path = os.path.splitext(os.path.basename(__file__))[0] + ".png"
   plt.savefig(output_path)
   ```

4. **Appropriate Diagrams**:
   - Choose the chart type (line, bar, scatter, etc.) that best represents the data.
   - Include appropriate labels, titles, and legends in Japanese where applicable.

## Workflow

1. Identify the data to be visualized.
2. Determine the script name (e.g., `stats-diagram.py`).
3. Generate the script using the template logic.
4. If requested, execute the script to verify output.

## Reference Template

See [references/template.py](references/template.py) for a complete example structure.