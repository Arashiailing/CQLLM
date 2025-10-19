/**
 * @name Function Invocation Frequency
 * @description Calculates the total number of function calls within each callable unit.
 *              This metric identifies functions with high call density, which may represent
 *              performance constraints or require optimization efforts.
 * @kind treemap
 * @id py/number-of-calls-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Python analysis module for source code metrics extraction

// Extract function metrics and compute call frequency
// Results are prioritized by descending call count to highlight
// functions with the highest invocation rates
from FunctionMetrics callableMetrics
select callableMetrics, callableMetrics.getNumberOfCalls() as invocationCount order by invocationCount desc