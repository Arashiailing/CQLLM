/**
 * @name Number of parameters without defaults
 * @description Calculates the count of function parameters that lack default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python analysis library to enable processing of Python code

// Identify function metrics and determine the quantity of parameters without default values
from FunctionMetrics funcMetric
select 
  funcMetric, 
  funcMetric.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by 
  nonDefaultParamCount desc
// Display function objects along with their counts of parameters lacking defaults, sorted in descending order