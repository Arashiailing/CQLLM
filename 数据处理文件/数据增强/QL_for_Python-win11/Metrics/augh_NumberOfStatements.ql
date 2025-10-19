/**
 * @name Number of statements
 * @description Calculates and displays the total count of statements within each Python module
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python

from Module moduleObj, int statementCount
where 
  // Define a variable to hold the count of statements per module
  statementCount = count(Stmt stmt | 
    // Filter statements that belong to the current module
    stmt.getEnclosingModule() = moduleObj
  )
// Select the module and its statement count, ordered by count in descending order
select moduleObj, statementCount order by statementCount desc