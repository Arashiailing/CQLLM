/**
 * @name Python File Function Count Analysis
 * @description Provides a quantitative analysis of function and method definitions across Python source files,
 *              excluding lambda expressions, to help identify potentially complex files that may require refactoring.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// For each Python module, compute the total number of defined functions and methods
from Module sourceFile, int funcCount
// Calculate the count by filtering out lambda functions and counting only those within the current module
where funcCount = count(Function func | 
       func.getEnclosingModule() = sourceFile and 
       not func.getName().matches("lambda"))
// Present results showing each module alongside its function count, ordered from highest to lowest
select sourceFile, funcCount order by funcCount desc