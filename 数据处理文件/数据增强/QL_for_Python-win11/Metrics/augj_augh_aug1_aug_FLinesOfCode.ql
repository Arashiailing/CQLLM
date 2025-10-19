/**
 * @name File Code Line Count
 * @kind treemap
 * @description Measures the actual lines of code in each Python file,
 *              disregarding documentation, comments, and blank lines.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// For each Python source file, determine the count of effective code lines
from Module sourceModule, int effectiveLines
where 
  // Exclude documentation, comments, and whitespace-only lines
  // to compute the effective line count
  effectiveLines = sourceModule.getMetrics().getNumberOfLinesOfCode()
// Display the Python files along with their code line counts,
// arranged in descending order to emphasize files with higher code volume
select sourceModule, effectiveLines order by effectiveLines desc