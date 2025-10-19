/**
 * @name Total lines of Python code in the database
 * @description Calculates the aggregate count of non-empty, non-comment lines across all
 *   Python files in the database. This metric includes both application code and external
 *   dependencies, providing a comprehensive measure of the codebase size.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python

// For each Python module, get its line count and sum them all
select sum(Module pyModule | | pyModule.getMetrics().getNumberOfLinesOfCode())