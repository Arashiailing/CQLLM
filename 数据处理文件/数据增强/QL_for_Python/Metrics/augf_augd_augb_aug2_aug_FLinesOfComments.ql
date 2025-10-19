/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Calculates the total number of comment lines in Python files,
 *              including both inline comments and docstrings. This metric
 *              excludes pure code lines and lines containing only whitespace.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import Python analysis module for structural code analysis capabilities

// Calculate the total comment lines for each Python module
// This combines both inline comments and docstring lines
from Module pythonModule, int totalCommentLines
where 
  totalCommentLines = pythonModule.getMetrics().getNumberOfLinesOfComments() +
                      pythonModule.getMetrics().getNumberOfLinesOfDocStrings()
select pythonModule, totalCommentLines order by totalCommentLines desc