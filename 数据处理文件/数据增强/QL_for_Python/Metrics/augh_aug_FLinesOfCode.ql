/**
 * @name Source File Code Lines Analysis
 * @kind treemap
 * @description Computes the effective lines of code for each Python file, ignoring
 *              documentation strings, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// This query follows a two-step process:
// 1. Identify all Python modules in the codebase
// 2. Calculate the effective code line count for each module
from Module sourceModule, int codeLineCount
where 
  // Step 2: Retrieve the count of meaningful code lines, excluding non-code elements
  codeLineCount = sourceModule.getMetrics().getNumberOfLinesOfCode()
// Present the results, highlighting modules with the highest code line counts first
select sourceModule, codeLineCount order by codeLineCount desc