/**
 * @name Count of function parameters without default values
 * @description Calculates the number of function parameters that are not assigned default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python analysis library for code processing capabilities

from FunctionMetrics funcMetrics
  // Extract function metrics to evaluate parameter default value assignments

select 
  funcMetrics, 
  funcMetrics.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
  // Present each function along with its count of parameters without default values

order by 
  nonDefaultParamCount desc
  // Arrange the results showing functions with the most non-default parameters first