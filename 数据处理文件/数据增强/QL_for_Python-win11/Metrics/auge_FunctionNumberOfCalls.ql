/**
 * @name Function call count analysis
 * @description Measures the total quantity of invocations within each function.
 * @kind treemap
 * @id py/function-call-metrics
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Import python library for Python code analysis

// Define the metric for counting function calls
from FunctionMetrics functionMetric

// Calculate and retrieve the number of calls for each function
where exists(functionMetric.getNumberOfCalls())

// Select the function and its call count, ordered by call count in descending order
select functionMetric, functionMetric.getNumberOfCalls() as callCount order by callCount desc