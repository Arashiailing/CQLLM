/**
 * @name Number of calls
 * @description Measures the total number of invocations within each callable unit.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Import Python analysis module for source code metrics

// This query identifies all callable units in the codebase and counts
// the number of calls each one contains. The results are ordered by
// call frequency in descending order to highlight the most active functions.

// Define the source: retrieve metrics for all callable units
from FunctionMetrics callableMetric

// Calculate and select the number of calls per callable unit
select callableMetric, callableMetric.getNumberOfCalls() as invocationCount

// Sort results to prioritize functions with higher call counts
order by invocationCount desc