/**
 * @name Statement Count Analysis
 * @description Calculates and presents the quantity of statements in each Python module.
 *              This metric helps identify potentially complex files that could be candidates for refactoring.
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python language library for analyzing Python code structure

// Define query result variables: source code module and its statement quantity
from Module sourceModule, int stmtQuantity
// Calculate the total number of statements in each module
where 
    // For each module, count all statements that belong to it
    stmtQuantity = count(Stmt codeStmt | 
        codeStmt.getEnclosingModule() = sourceModule)
// Return result set: module object and its corresponding statement count, sorted in descending order by statement quantity
select sourceModule, stmtQuantity order by stmtQuantity desc