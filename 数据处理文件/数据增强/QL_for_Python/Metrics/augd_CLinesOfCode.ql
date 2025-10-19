/**
 * @name Lines of code in functions
 * @description Calculates and displays the number of lines of code for each function in a Python codebase.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import the Python module for analyzing Python source code

// Query to retrieve all Python functions and their corresponding line counts
from Function pythonFunction, int lineCount
where 
  lineCount = pythonFunction.getMetrics().getNumberOfLinesOfCode()
select 
  pythonFunction, 
  lineCount 
order by 
  lineCount desc