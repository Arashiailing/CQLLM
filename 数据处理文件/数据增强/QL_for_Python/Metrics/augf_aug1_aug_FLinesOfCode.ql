/**
 * @name File Code Line Count
 * @kind treemap
 * @description Computes the number of actual code lines in each Python file, 
 *              excluding lines with only docstrings, comments, or whitespace.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Identify Python source modules and calculate their effective code line counts
from Module pythonModule, int effectiveLinesCount
where 
  // For each Python module, determine the count of lines containing real code,
  // filtering out documentation, comments, and blank lines
  effectiveLinesCount = pythonModule.getMetrics().getNumberOfLinesOfCode()
// Output the Python modules along with their corresponding effective code line counts,
// sorted in descending order based on line count
select pythonModule, effectiveLinesCount order by effectiveLinesCount desc