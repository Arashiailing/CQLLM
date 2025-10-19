/**
 * @name Python File Code Line Analysis
 * @kind treemap
 * @description Analyzes and counts the effective lines of code in Python source files,
 *              excluding lines with only docstrings, comments, or whitespace.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// This query processes Python source files to calculate their effective code line counts,
// filtering out documentation, comments, and whitespace-only lines
from Module sourceFile, int effectiveLineCount
where 
  // For each Python module, compute the count of lines containing actual code
  effectiveLineCount = sourceFile.getMetrics().getNumberOfLinesOfCode()
// Output the source files along with their respective code line counts,
// ordered from highest to lowest line count
select sourceFile, effectiveLineCount order by effectiveLineCount desc