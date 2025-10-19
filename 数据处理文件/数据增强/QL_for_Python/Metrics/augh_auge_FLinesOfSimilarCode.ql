/**
 * @deprecated
 * @name Similar lines in files
 * @description Quantifies duplicate content across files by counting lines (including code, 
 *              comments, and whitespace) that appear in at least one other location.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python

// Define analysis variables: target file and its similarity metric
from File analyzedFile, int duplicateLineCount

// Apply no filtering constraints (preserves original behavior)
where none()

// Output results ordered by similarity metric in descending order
select analyzedFile, duplicateLineCount 
order by duplicateLineCount desc