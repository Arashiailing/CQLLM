/**
 * @name Lines of code in functions
 * @description Computes and displays the line count for each function in a Python codebase.
 * @kind treemap
 * @id py/lines-of-code-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg sum max
 * @tags maintainability
 */

import python // Import the Python module for analyzing Python source code

// Retrieve all Python functions with their corresponding line counts
from Function func, int loc
where 
  loc = func.getMetrics().getNumberOfLinesOfCode()
select 
  func, 
  loc 
order by 
  loc desc