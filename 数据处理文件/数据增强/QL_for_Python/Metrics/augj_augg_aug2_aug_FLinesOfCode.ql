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

// For each Python source file in the project, compute the effective code line count
from Module sourceFile, int actualCodeLines
where 
  // Retrieve the count of lines containing actual code, excluding comments,
  // docstrings, and whitespace-only content
  actualCodeLines = sourceFile.getMetrics().getNumberOfLinesOfCode()
// Output results ordered by code line count in descending order to highlight
// files with the highest volume of executable code
select sourceFile, actualCodeLines order by actualCodeLines desc