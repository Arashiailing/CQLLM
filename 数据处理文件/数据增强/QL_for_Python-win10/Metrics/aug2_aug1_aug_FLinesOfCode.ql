/**
 * @name File Code Line Count
 * @kind treemap
 * @description Calculates the total lines of code in each file (excluding lines that
 *              only contain docstrings, comments or whitespace).
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Identify Python source modules and compute their effective code line counts
from Module pyModule, int effectiveLineCount
where 
  // Calculate lines containing actual code, excluding documentation, comments, and whitespace
  effectiveLineCount = pyModule.getMetrics().getNumberOfLinesOfCode()
// Return modules sorted by descending line count for maintainability analysis
select pyModule, effectiveLineCount order by effectiveLineCount desc