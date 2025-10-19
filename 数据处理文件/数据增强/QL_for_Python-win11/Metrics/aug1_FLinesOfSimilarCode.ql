/**
 * @deprecated
 * @name Similar lines in files
 * @description Measures the count of lines in a file (including code, comments, and whitespace)
 *              that have similarity with at least one other location.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python

from File sourceFile, int duplicateLineCount
where none()
select sourceFile, duplicateLineCount order by duplicateLineCount desc