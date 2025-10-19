/**
 * @deprecated
 * @name Similar lines in files
 * @description The number of lines in a file, including code, comment and whitespace lines,
 *              which are similar in at least one other place.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python

// Define analysis variables for file similarity detection
from File sourceFile, int duplicateLineCount

// Apply unconditional filter to preserve original logic
where none()

// Output results with descending ordering
select sourceFile, duplicateLineCount 
order by duplicateLineCount desc