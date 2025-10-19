/**
 * @name File Code Line Count
 * @kind treemap
 * @description Computes the effective lines of code for each Python file, 
 *              excluding documentation, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Identify Python modules and calculate their effective code line count
from Module pyModule, int locCount
where 
  // Calculate the number of lines containing actual code by excluding
  // documentation, comments, and whitespace-only lines
  locCount = pyModule.getMetrics().getNumberOfLinesOfCode()
// Output the Python modules and their corresponding line counts,
// sorted in descending order to highlight files with the most code
select pyModule, locCount order by locCount desc