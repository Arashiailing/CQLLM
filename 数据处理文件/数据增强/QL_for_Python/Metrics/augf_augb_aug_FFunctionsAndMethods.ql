/**
 * @name Module Function Count Analysis
 * @description Provides a statistical overview of function and method density across Python source files.
 * @kind treemap
 * @id py/function-density-per-module
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// Identify each module and calculate its function population
from Module moduleContainer, int functionCount
// Compute the total number of non-lambda functions contained within each module
where functionCount = count(Function functionItem | 
       functionItem.getEnclosingModule() = moduleContainer and 
       functionItem.getName() != "lambda")
// Display results showing modules and their respective function counts, arranged by count in descending sequence
select moduleContainer, functionCount order by functionCount desc