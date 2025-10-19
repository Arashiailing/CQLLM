/**
 * @name File Code Line Count
 * @kind treemap
 * @description Computes the number of actual code lines in each Python file,
 *              excluding lines that solely contain docstrings, comments, or whitespace.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// Query to fetch Python modules and determine their effective code line counts
from Module sourceModule, int codeLineCount
where 
  // Extract the count of genuine code lines, disregarding documentation and comment lines
  codeLineCount = sourceModule.getMetrics().getNumberOfLinesOfCode()
// Display the file modules along with their code line counts, arranged in descending order
select sourceModule, codeLineCount order by codeLineCount desc