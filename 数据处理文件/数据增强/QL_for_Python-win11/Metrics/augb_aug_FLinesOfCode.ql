/**
 * @name File Code Line Count
 * @kind treemap
 * @description Computes the total lines of code per Python file, excluding 
 *              documentation, comments, and whitespace-only lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Define source file and its code line count
from Module sourceFile, int codeLines 
where 
  // Calculate actual code lines (excluding non-code elements)
  codeLines = sourceFile.getMetrics().getNumberOfLinesOfCode()
// Output files sorted by code line count (descending)
select sourceFile, codeLines order by codeLines desc