/**
 * @name File-level function and method count
 * @description Provides complexity analysis of Python source files by measuring the quantity
 *              of explicitly named functions and methods within each module. Lambda expressions
 *              are deliberately excluded from this count. This metric helps identify potentially
 *              over-complicated files that might benefit from refactoring to improve maintainability.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import the Python analysis module to access code structure definitions

// Process each Python module to determine its function/method density
from Module pyModule, int functionCount
// Compute the total number of named functions and methods within the module
where functionCount = count(Function functionDefinition | 
       // Verify that the function is defined within the current module scope
       functionDefinition.getEnclosingModule() = pyModule and 
       // Exclude anonymous lambda functions, counting only explicitly named functions
       functionDefinition.getName() != "lambda")
// Generate output showing modules and their function counts, sorted in descending order
select pyModule, functionCount order by functionCount desc