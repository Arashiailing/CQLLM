/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Computes the aggregate count of comment lines in each Python file.
 *              This includes both inline comments and docstrings, while excluding
 *              pure code lines and blank lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import Python module for code structure analysis

// For each Python module, calculate the combined total of comment and docstring lines
from Module sourceFile, int annotationLineCount
where
  // First, get the regular comment line count
  annotationLineCount = sourceFile.getMetrics().getNumberOfLinesOfComments() and
  // Then, add the docstring line count to the total
  annotationLineCount = annotationLineCount + sourceFile.getMetrics().getNumberOfLinesOfDocStrings()
select sourceFile, annotationLineCount order by annotationLineCount desc