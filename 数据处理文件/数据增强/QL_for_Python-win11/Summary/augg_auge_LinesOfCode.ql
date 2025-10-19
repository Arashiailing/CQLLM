/**
 * @name Total lines of Python code in the database
 * @description Calculates the aggregate count of Python code lines throughout the entire
 *   database, encompassing both external libraries and auto-generated files. This metric
 *   serves as an indicator of the database's overall code volume. The calculation
 *   specifically excludes blank lines and comments, focusing solely on actual code lines.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // Import the Python analysis module for code metrics extraction

// Calculate the total number of Python code lines across all modules in the database
select sum(Module pyModule | | pyModule.getMetrics().getNumberOfLinesOfCode())
// Explanation of components:
// - `Module`: Represents a Python module in the analyzed codebase
// - `pyModule`: Variable that iterates over each Python module
// - `getMetrics()`: Retrieves the metrics object containing code statistics
// - `getNumberOfLinesOfCode()`: Extracts the count of non-blank, non-comment code lines
// - `sum(...)`: Aggregation function that totals the code lines from all modules