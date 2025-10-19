/**
 * @name Python Module Statement Complexity Analyzer
 * @description Computes and displays the number of statements within each Python module.
 *              This metric serves as an indicator of file complexity, highlighting modules
 *              that may benefit from refactoring due to their size.
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python language library for analyzing Python code structure

// Define query result variables: target module and its statement count
from Module targetModule, int statementCount
// Calculate the total number of statements in each module
where 
    // For each module, count all statements that belong to it
    statementCount = count(Stmt moduleStatement | 
        moduleStatement.getEnclosingModule() = targetModule)
// Return result set: module object and its corresponding statement count, sorted in descending order by statement count
select targetModule, statementCount order by statementCount desc