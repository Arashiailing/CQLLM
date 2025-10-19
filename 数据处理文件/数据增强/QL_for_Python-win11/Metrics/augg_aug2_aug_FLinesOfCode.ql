/**
 * @name File Code Line Count
 * @kind treemap
 * @description This query analyzes Python source files to determine the effective
 *              lines of code in each file. It excludes lines that contain only
 *              docstrings, comments, or whitespace, providing a more accurate
 *              measure of actual code volume.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Identify all Python modules and calculate their effective code line count
from Module pythonModule, int effectiveLineCount
where 
  // Compute the number of lines containing actual code (excluding comments and whitespace)
  effectiveLineCount = pythonModule.getMetrics().getNumberOfLinesOfCode()
// Present the results with modules sorted by their code line count in descending order
select pythonModule, effectiveLineCount order by effectiveLineCount desc