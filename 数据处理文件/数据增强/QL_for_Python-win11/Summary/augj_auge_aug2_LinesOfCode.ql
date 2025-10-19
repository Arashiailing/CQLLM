/**
 * @name Total lines of Python code in the database
 * @description Calculates the cumulative number of lines of Python code throughout
 *   the entire database, encompassing both external dependencies and generated files.
 *   This measurement offers a comprehensive view of the codebase magnitude. The computation
 *   disregards blank lines and comments, concentrating solely on executable code lines.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // Import the Python analysis module for code analysis capabilities

// This query performs an aggregation of all Python code lines in the database
// The computation process involves:
// 1. Iterating through each Python module in the codebase
// 2. Extracting the line count metrics for each module
// 3. Summing these counts to produce the final total
// Note: The calculation excludes whitespace-only lines and comments
from Module codeModule
select sum(codeModule.getMetrics().getNumberOfLinesOfCode())