/**
 * @name Count of non-default parameters
 * @description Measures how many function parameters lack default value assignments.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python

// Extract function metrics from analyzed codebase
from FunctionMetrics callableEntity
// Select each callable with its count of parameters lacking default values
// Results are sorted in descending order by parameter count
select 
  callableEntity, 
  callableEntity.getNumberOfParametersWithoutDefault() as paramCount 
order by paramCount desc