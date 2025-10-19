/**
 * @name Count of non-default parameters
 * @description Computes the quantity of function parameters that do not have default values assigned.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Python module import for enabling static analysis capabilities on Python code

// Identify all functions for analysis and extract their mandatory parameter count
from FunctionMetrics analyzedFunction
select analyzedFunction, 
       analyzedFunction.getNumberOfParametersWithoutDefault() as mandatoryParamCount 
// Order results by mandatory parameter count in descending sequence
order by mandatoryParamCount desc