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

// Query logic breakdown:
// 1. Identify all Python modules in the codebase
// 2. Extract code metrics for each module
// 3. Retrieve the count of actual code lines (excluding blanks/comments)
// 4. Calculate the sum across all modules
select sum(Module pythonModule | | 
  pythonModule.getMetrics().getNumberOfLinesOfCode()
)