/**
 * @name Python Function Invocation Counter
 * @description Quantifies the total number of function calls made within each Python function.
 *              This metric serves as an indicator of function complexity, helping to identify
 *              functions that may require refactoring or detailed review due to high call volume.
 * @kind treemap
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Import Python library for analyzing Python code

// Extract metrics data for every function present in the Python codebase
from FunctionMetrics functionMetrics

// Output each function with its respective invocation count, ordered from highest to lowest
select functionMetrics, functionMetrics.getNumberOfCalls() as invocationCount order by invocationCount desc