/**
 * @deprecated
 * @name Similar lines in files
 * @description Detects files with duplicated code/comment/whitespace lines 
 *              appearing in multiple locations. Reports per-file duplicate line counts.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python

// Select source file and its duplicate line count
from File sourceFile, int duplicatedLineCount
where 
  // Universal condition (matches all files as per original logic)
  none() 
select 
  sourceFile, 
  duplicatedLineCount 
order by 
  duplicatedLineCount desc