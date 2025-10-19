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

// This query identifies Python modules and computes their effective code lines
// by excluding documentation, comments, and whitespace-only content
from Module pyModule, int locCount
where 
  // Calculate the number of effective code lines for each Python module
  locCount = pyModule.getMetrics().getNumberOfLinesOfCode()
// Return the Python modules along with their effective line counts,
// sorted in descending order to highlight files with the most code
select pyModule, locCount order by locCount desc