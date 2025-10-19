/**
 * @name Count of non-default parameters
 * @description Calculates the number of function parameters that are not assigned default values.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python module to enable static analysis capabilities on Python source code

// Identify all functions for analysis and extract their count of parameters without default values
from FunctionMetrics examinedFunction
select examinedFunction, 
       examinedFunction.getNumberOfParametersWithoutDefault() as requiredParamCount 
// Order results by the count of required parameters in descending order
order by requiredParamCount desc