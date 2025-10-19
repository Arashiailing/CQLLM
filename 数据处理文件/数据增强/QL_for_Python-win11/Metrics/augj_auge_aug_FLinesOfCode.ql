/**
 * @name File Code Line Count
 * @kind treemap
 * @description Analyzes Python source files to determine the quantity of actual code lines,
 *              excluding documentation, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Retrieve Python modules and calculate their effective line counts
from Module pyModule, int effectiveLineCount
where 
  // Compute the number of lines containing actual code, excluding non-code elements
  effectiveLineCount = pyModule.getMetrics().getNumberOfLinesOfCode()
// Output the modules with their respective code line counts, sorted in descending order
select pyModule, effectiveLineCount order by effectiveLineCount desc