/**
 * @name Function Call Frequency Analysis
 * @description Quantifies total function invocations within each callable entity
 * @kind treemap
 * @id py/function-call-frequency
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Python analysis library for code metrics computation

// Analyze callable entities to measure invocation patterns
from FunctionMetrics callableMetrics
// Report each callable entity with its invocation count, sorted by frequency
select 
    callableMetrics, 
    callableMetrics.getNumberOfCalls() as invocationCount 
order by 
    invocationCount desc