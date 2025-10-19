/**
 * @name Number of statements
 * @description Computes and displays the count of statements within each Python module.
 *              This metric assists in locating potentially complex files that might benefit from refactoring efforts.
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python language library for analyzing Python code structure

// Define query result variables: source code module and its statement count
from Module pyModule, int statementCount
// Calculate the total number of statements in each module
where 
    // Aggregate computation: iterate through all statements and count those belonging to the current module
    statementCount = count(Stmt statement | statement.getEnclosingModule() = pyModule)
// Return result set: module object and its corresponding statement count, sorted in descending order by statement count
select pyModule, statementCount order by statementCount desc