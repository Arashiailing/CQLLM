/**
 * @name Total lines of Python code in the database
 * @description Computes the aggregate count of Python code lines throughout the entire database,
 *   encompassing both external libraries and auto-generated files. This metric offers valuable
 *   insights into the overall scale of the codebase. The calculation deliberately excludes
 *   whitespace and comment lines, concentrating exclusively on actual code implementation.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // Import Python analysis module to enable Python code analysis capabilities

// Calculate the total number of effective code lines across all Python modules
select sum(Module pyModule | | pyModule.getMetrics().getNumberOfLinesOfCode())
// Key components:
// - `Module` class: Represents individual Python code modules in the database
// - `pyModule` variable: Instance variable referring to each Python module
// - `getMetrics().getNumberOfLinesOfCode()`: Method chain that retrieves the count of non-blank,
//   non-comment code lines for each module
// - `sum(...)`: Aggregation function that computes the cumulative total of code lines