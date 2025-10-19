/**
 * @name Python source file comment density analysis
 * @description Calculates the ratio of comment lines to total lines in Python source files.
 *              This metric helps assess code documentation quality. Note that docstrings
 *              are excluded from this calculation and are handled separately.
 * @kind treemap
 * @id py/comment-density-per-file
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg max
 * @tags maintainability
 *       documentation
 */

import python

from Module sourceFile
where sourceFile.getMetrics().getNumberOfLines() > 0
select sourceFile, 100.0 * sourceFile.getMetrics().getNumberOfLinesOfComments() / sourceFile.getMetrics().getNumberOfLines() as densityValue
order by densityValue desc