/**
 * @name Number of calls
 * @description Counts the total number of function calls within each Python function.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Import Python library for analyzing Python code

// Query to retrieve functions along with their call counts, ordered by call count in descending order
from FunctionMetrics callableMetric
select callableMetric, callableMetric.getNumberOfCalls() as callCount order by callCount desc