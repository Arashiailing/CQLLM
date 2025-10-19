/**
 * @name Callable invocation count analysis
 * @description Quantifies the total number of invocations within each callable entity.
 * @kind treemap
 * @id py/callable-invocation-metrics
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Import python library for Python code analysis

// Define and filter callable metrics that have invocation counts
from FunctionMetrics callableMetric
where callableMetric.getNumberOfCalls() > 0

// Select the callable entity and its invocation count, ordered by invocation count in descending order
select callableMetric, callableMetric.getNumberOfCalls() as invocationCount order by invocationCount desc