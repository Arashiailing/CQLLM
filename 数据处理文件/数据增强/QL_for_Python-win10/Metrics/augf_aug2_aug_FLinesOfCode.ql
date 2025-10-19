/**
 * @name File Code Line Count
 * @kind treemap
 * @description Computes the effective lines of code for each Python file, ignoring
 *              lines that solely consist of docstrings, comments, or whitespace.
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 * @id py/lines-of-code-in-files
 */

import python

// For each Python module, calculate and retrieve its effective line count
from Module moduleFile, int locCount
where 
  locCount = moduleFile.getMetrics().getNumberOfLinesOfCode()
// Present modules sorted by their code line counts in descending order
select moduleFile, locCount order by locCount desc