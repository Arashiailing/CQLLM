/**
 * @name Functions and methods per file
 * @description Calculates the count of functions and methods within each Python file.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import Python module for code structure analysis

// For each Python module, compute the total number of defined functions and methods
from Module moduleFile, int functionCount
// Calculate the count by filtering out lambda functions and counting only those within the current module
where functionCount = count(Function method | 
       method.getEnclosingModule() = moduleFile and 
       not method.getName().matches("lambda"))
// Present results showing each module alongside its function count, ordered from highest to lowest
select moduleFile, functionCount order by functionCount desc