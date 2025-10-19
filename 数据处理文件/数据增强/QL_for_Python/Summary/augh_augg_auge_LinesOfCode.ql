/**
 * @name Aggregate count of Python code lines
 * @description Computes the total number of actual code lines in the Python codebase,
 *   including all modules, libraries, and generated files. This metric provides insight
 *   into the overall size of the codebase by counting only executable lines, excluding
 *   blank lines and comments.
 * @kind metric
 * @tags summary
 *       telemetry
 * @id py/summary/lines-of-code
 */

import python // Import the Python analysis module for code metrics extraction

// The following query calculates the total lines of code by:
// 1. Iterating through all Python modules in the database
// 2. For each module, getting its code metrics
// 3. Extracting the number of actual code lines (excluding blanks and comments)
// 4. Summing these values across all modules
select sum(Module mod | | mod.getMetrics().getNumberOfLinesOfCode())