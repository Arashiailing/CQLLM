/**
 * @name Total lines of Python code in the database
 * @description Computes the aggregate count of lines of Python code across all files
 *   in the database, including external libraries and auto-generated files. This metric
 *   provides insight into the overall size of the codebase. The calculation excludes
 *   whitespace and comment lines, focusing only on actual code lines.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // Import the Python analysis module for code analysis capabilities

// Calculate the total lines of code across all Python modules
from Module pyModule
select sum(pyModule.getMetrics().getNumberOfLinesOfCode())
// Explanation:
// - `Module` represents Python code modules in the database
// - `pyModule` is an instance variable referring to each Python module
// - `getMetrics().getNumberOfLinesOfCode()` retrieves the count of non-whitespace,
//   non-comment lines of code in the module
// - `sum(...)` aggregates the line counts from all modules into a total