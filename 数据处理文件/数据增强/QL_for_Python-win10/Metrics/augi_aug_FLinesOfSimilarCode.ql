/**
 * @deprecated
 * @name Repeated lines across files
 * @description Identifies and counts duplicate lines within a file (including all content types)
 *              that have matching occurrences in other files.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python // Python code analysis module for processing Python source files

// Query to find files with their respective duplicate line counts
from File sourceFile, int duplicateLineCount
where 
  none() // No filtering conditions applied
select 
  sourceFile, 
  duplicateLineCount 
order by 
  duplicateLineCount desc // Results sorted by duplicate count in descending order