/**
 * @name Statement count analysis
 * @description Measures the total number of statements within each Python source file.
 *              This analysis assists in detecting overly complex modules that might benefit from refactoring efforts.
 * @kind treemap
 * @id py/number-of-statements-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 */

import python // Import Python language module for analyzing Python code structures

// Define the output format: Python source file and its corresponding statement count
from Module sourceFile, int totalStatements
// Apply filtering condition: tally all statements within each module
where 
    // Calculate the total statements by counting each statement belonging to the current module
    totalStatements = count(Stmt codeStatement | codeStatement.getEnclosingModule() = sourceFile)
// Select the source file and its statement count, sorted in descending order to highlight most complex files
select sourceFile, totalStatements order by totalStatements desc