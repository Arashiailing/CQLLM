/**
 * @name File Code Line Count
 * @kind treemap
 * @description Provides a count of meaningful code lines in each Python file,
 *              excluding lines that contain only docstrings, comments, or whitespace.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// For each Python module, determine its effective line count
from Module pyModule, int effectiveLineCount
where 
  // Calculate the number of actual code lines, ignoring comments and whitespace
  effectiveLineCount = pyModule.getMetrics().getNumberOfLinesOfCode()
// Present results sorted by line count in descending order
select pyModule, effectiveLineCount order by effectiveLineCount desc