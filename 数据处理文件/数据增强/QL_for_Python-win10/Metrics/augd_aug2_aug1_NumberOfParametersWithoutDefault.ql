/**
 * @name Number of parameters without defaults
 * @description Computes the quantity of function parameters that do not have default values assigned.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python analysis module to enable code processing capabilities

// Extract function metrics and determine the count of parameters lacking default values
from FunctionMetrics functionMetric, int nonDefaultCount
where nonDefaultCount = functionMetric.getNumberOfParametersWithoutDefault()
select 
  functionMetric, 
  nonDefaultCount 
order by 
  nonDefaultCount desc
// Display function entities along with their respective counts of parameters without defaults, sorted in descending order