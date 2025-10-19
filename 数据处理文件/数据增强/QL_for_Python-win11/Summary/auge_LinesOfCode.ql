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

import python // Import Python module to handle Python code analysis

// Compute the total lines of code by aggregating across all Python modules
select sum(Module codeModule | | codeModule.getMetrics().getNumberOfLinesOfCode())
// Detailed explanation:
// - `Module`: Represents a Python code module within the analyzed codebase
// - `codeModule`: An instance variable representing each individual Python module
// - `getMetrics()`: Method call to retrieve code metrics for the module
// - `getNumberOfLinesOfCode()`: Method call to extract the count of code lines
// - `sum(...)`: Aggregation function that calculates the total across all modules