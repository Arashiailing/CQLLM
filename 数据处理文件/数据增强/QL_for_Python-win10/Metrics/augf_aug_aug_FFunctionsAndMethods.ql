/**
 * @name Functions and methods per file
 * @description Provides a statistical analysis of function and method density across Python files.
 * @kind treemap
 * @id py/functions-and-methods-per-file
 * @treemap.warnOn highValues
 * @metricType file
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import the Python module to enable analysis of Python code structure

// For each Python module, compute the total number of defined functions and methods
from Module pyFile
// Present the module along with its function count, sorted from highest to lowest count
select pyFile, count(Function fn | fn.getEnclosingModule() = pyFile and fn.getName() != "lambda") as functionCount 
order by functionCount desc