/**
 * @name File Code Line Count
 * @kind treemap
 * @description Provides a treemap visualization showing the distribution of 
 *              effective code lines across Python files. This metric excludes 
 *              documentation strings, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Analyze each Python module to determine its effective code line count
from Module pythonModule, int effectiveLineCount
where 
  // Calculate the number of lines containing actual code (excluding non-code elements)
  effectiveLineCount = pythonModule.getMetrics().getNumberOfLinesOfCode()
// Present results showing each module with its line count, sorted by highest count first
select pythonModule, effectiveLineCount order by effectiveLineCount desc