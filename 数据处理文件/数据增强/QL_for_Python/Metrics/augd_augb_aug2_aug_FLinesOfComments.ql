/**
 * @name File Comment Line Count
 * @kind treemap
 * @description Computes the aggregate count of comment lines for each Python file,
 *              encompassing both inline comments and docstrings, while excluding
 *              pure code lines and whitespace-only lines.
 * @treemap.warnOn lowValues
 * @metricType file
 * @metricAggregate avg sum max
 * @id py/lines-of-comments-in-files
 */

import python // Import Python analysis module for structural code analysis capabilities

// Define a helper variable to calculate the total comment lines for a module
// This includes both standard comment lines and docstring lines
from Module sourceFile, int commentLineCount
where 
  exists(int standardComments, int docstringComments |
    standardComments = sourceFile.getMetrics().getNumberOfLinesOfComments() and
    docstringComments = sourceFile.getMetrics().getNumberOfLinesOfDocStrings() and
    commentLineCount = standardComments + docstringComments
  )
select sourceFile, commentLineCount order by commentLineCount desc