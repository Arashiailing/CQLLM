/**
 * @name Number of statements
 * @description Analyzes Python codebases to calculate and visualize the quantity of statements 
 *              within each module. This metric helps identify overly complex files that may 
 *              require refactoring to improve maintainability and readability.
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python language library for analyzing Python code structure

// Define query result variables: source code module and its statement count
from Module pythonModule, int stmtCount
// Calculate the total number of statements in each module
where 
    // Aggregate computation: count all statements that belong to the current module
    stmtCount = count(Stmt stmt | stmt.getEnclosingModule() = pythonModule)
// Return result set: module object and its corresponding statement count, sorted in descending order by statement count
select pythonModule, stmtCount order by stmtCount desc