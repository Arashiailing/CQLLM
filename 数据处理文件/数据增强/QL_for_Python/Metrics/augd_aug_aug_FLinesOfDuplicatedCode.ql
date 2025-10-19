/**
 * @deprecated This query is deprecated and not recommended for use
 * @name Duplicated lines in files
 * @description Counts total lines (code, comments, whitespace) that appear more than once in the codebase
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/duplicated-lines-in-files
 */

import python

// Main query logic: retrieve target files and their duplicate line metrics
from File sourceFile, int lineDuplicationMetric
where 
  // Placeholder condition: no actual filtering logic (preserving original design intent)
  none()
// Output results: file objects and duplicate line counts, ordered by duplication level in descending order
select sourceFile, lineDuplicationMetric order by lineDuplicationMetric desc