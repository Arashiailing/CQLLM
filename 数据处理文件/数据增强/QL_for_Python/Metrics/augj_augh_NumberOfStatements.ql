/**
 * @name Statement count per Python module
 * @description Quantifies the total number of statements across each Python module in the codebase
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

from Module sourceModule, int stmtCount
where 
  // Compute the aggregate count of statements for each module
  stmtCount = count(Stmt statement | 
    // Restrict count to statements belonging to the current module
    statement.getEnclosingModule() = sourceModule
  )
// Return modules with their respective statement counts, ordered by count (highest first)
select sourceModule, stmtCount order by stmtCount desc