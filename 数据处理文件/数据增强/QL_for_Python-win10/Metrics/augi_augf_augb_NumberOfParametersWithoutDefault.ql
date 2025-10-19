/**
 * @name Non-default parameter count analysis
 * @description Calculates the number of function parameters that do not have default values assigned.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python

// Analyze function metrics to identify parameters without default values
from FunctionMetrics functionEntity
// Select each function along with its count of parameters lacking default assignments
// Results are presented in descending order based on the parameter count
select 
  functionEntity, 
  functionEntity.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by nonDefaultParamCount desc