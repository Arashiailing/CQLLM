/**
 * @deprecated
 * @name File line similarity detection
 * @description Identifies and counts lines within a file (including code, comments, 
 *              and whitespace) that have similar occurrences in other locations.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags testability
 * @id py/similar-lines-in-files
 */

import python // Module for analyzing Python source code

// Query to find files and their respective line similarity counts
from File sourceFile, int duplicateLineCount
where 
  none() // Temporary condition - no actual filtering is performed
select 
  sourceFile, 
  duplicateLineCount 
order by 
  duplicateLineCount desc // Arrange results with highest similarity counts first