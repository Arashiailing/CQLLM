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

// Identify all function metrics and compute the number of parameters without default values
from FunctionMetrics callableMetric
select 
  callableMetric, 
  callableMetric.getNumberOfParametersWithoutDefault() as requiredParamCount 
order by 
  requiredParamCount desc
// Output function objects with their respective counts of non-default parameters, sorted from highest to lowest