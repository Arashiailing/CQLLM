/**
 * @name Total lines of Python code in the database
 * @description This query computes the total number of Python code lines across the entire
 *   codebase, including both third-party libraries and generated files. The metric provides
 *   insight into the overall size of the codebase. Note that only actual code lines are
 *   counted, with blank lines and comments excluded from the calculation.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // Import Python module to enable analysis of Python code

// Aggregate the total lines of code across all Python modules in the database
select sum(Module pyModule | | pyModule.getMetrics().getNumberOfLinesOfCode())
// Explanation of key components:
// - `Module`: Represents a Python module in the analyzed codebase
// - `pyModule`: Variable representing each individual Python module
// - `getMetrics()`: Method to obtain code metrics for the module
// - `getNumberOfLinesOfCode()`: Method to retrieve the count of code lines
// - `sum(...)`: Aggregation function calculating the total across all modules