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

// This query analyzes Python modules to count all regular functions and methods,
// excluding lambda expressions which are anonymous functions typically used for inline operations.
from Module pythonModule, int functionMethodCount
where 
  // Calculate the total count by filtering functions that:
  // 1. Belong to the current module being analyzed
  // 2. Are not lambda expressions (identified by "lambda" in their name)
  functionMethodCount = count(Function functionOrMethod | 
    functionOrMethod.getEnclosingModule() = pythonModule and 
    not functionOrMethod.getName().matches("lambda")
  )
// Display results with modules sorted by function/method count in descending order
select pythonModule, functionMethodCount order by functionMethodCount desc