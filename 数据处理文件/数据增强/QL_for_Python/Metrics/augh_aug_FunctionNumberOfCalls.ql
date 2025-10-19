/**
 * @name Function Call Frequency Analysis
 * @description Analyzes and counts the total number of function calls within each callable entity.
 * @kind treemap
 * @id py/function-call-frequency
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 */

import python  // Import Python analysis library for code metrics computation

// Extract function metrics data to analyze call patterns
from FunctionMetrics funcMetric
// Select each callable entity and compute its call frequency, ordered by frequency in descending order
select 
    funcMetric, 
    funcMetric.getNumberOfCalls() as callFrequency 
order by 
    callFrequency desc