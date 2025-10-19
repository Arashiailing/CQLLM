/**
 * @deprecated
 * @name Similar lines in files
 * @description Identifies files containing code/comment/whitespace lines that 
 *              appear in at least one other location. Reports the count of 
 *              such duplicated lines per file.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python

// Select file and duplicate line count pairs
from File targetFile, int duplicateLineCount
where 
  // No filtering constraints applied (matches original logic)
  none() 
select 
  targetFile, 
  duplicateLineCount 
order by 
  duplicateLineCount desc