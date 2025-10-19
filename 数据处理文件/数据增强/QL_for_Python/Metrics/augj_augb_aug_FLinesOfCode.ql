/**
 * @name Python File Code Line Count
 * @kind treemap
 * @description Calculates the total number of code lines in each Python file,
 *              excluding documentation, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Define Python module and its line count metric
from Module moduleFile, int locCount
where 
  // Determine the actual code lines by excluding non-code elements
  locCount = moduleFile.getMetrics().getNumberOfLinesOfCode()
// Output modules sorted by line count in descending order
select moduleFile, locCount order by locCount desc