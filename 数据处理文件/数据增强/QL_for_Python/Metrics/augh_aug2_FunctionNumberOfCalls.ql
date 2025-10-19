/**
 * @name Number of calls
 * @description Quantifies the total number of function calls within each callable unit.
 *              This metric helps identify functions with high call frequency, which may
 *              indicate performance bottlenecks or areas requiring optimization.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Python analysis module for source code metrics extraction

// Retrieve function metrics and compute call frequency
// Results are sorted in descending order to prioritize functions
// with the highest number of invocations
from FunctionMetrics funcMetric
select funcMetric, funcMetric.getNumberOfCalls() as totalCalls order by totalCalls desc