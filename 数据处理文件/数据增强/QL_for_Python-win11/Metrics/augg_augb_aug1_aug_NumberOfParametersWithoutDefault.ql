/**
 * @name Non-default parameter count analysis
 * @description This analysis determines the number of function parameters that are not assigned default values,
 *              which can indicate function complexity and testability challenges.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Enables static analysis capabilities for Python code

// Source: All functions with metrics available for analysis
from FunctionMetrics examinedFunction
// Calculate and select the count of parameters without default values
select examinedFunction, 
       examinedFunction.getNumberOfParametersWithoutDefault() as requiredParamCount 
// Sort results to highlight functions with the most required parameters first
order by requiredParamCount desc