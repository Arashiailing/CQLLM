/**
 * @name Lines of code in files
 * @kind treemap
 * @description Measures the number of lines of code in each file (ignoring lines that
 *              contain only docstrings, comments or are blank).
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// This query calculates the effective code lines in each Python module
// by excluding documentation strings, comments, and blank lines
// Results are presented in descending order of code line count
from Module sourceFile, int effectiveLineCount
where 
  // Retrieve the count of actual code lines for each module
  effectiveLineCount = sourceFile.getMetrics().getNumberOfLinesOfCode()
select 
  sourceFile, 
  effectiveLineCount 
order by 
  effectiveLineCount desc