/**
 * @name Lines of code in files
 * @kind treemap
 * @description Calculates and visualizes the number of lines of code in each Python file.
 *              This metric excludes lines that only contain docstrings, comments, or are blank,
 *              providing a more accurate measure of actual code complexity.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Analyze each Python module to determine its code line count
from Module fileModule, int codeLineCount
where 
  // Retrieve the number of lines of code for each module, excluding documentation and blank lines
  codeLineCount = fileModule.getMetrics().getNumberOfLinesOfCode()
select 
  fileModule, 
  codeLineCount 
order by 
  codeLineCount desc