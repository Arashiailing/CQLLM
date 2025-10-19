/**
 * @name Count of non-default parameters
 * @description Identifies functions with parameters lacking default values.
 *              A high number of such parameters can decrease code maintainability
 *              and increase testing complexity. This metric helps identify functions
 *              that might benefit from refactoring.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Provides static analysis capabilities for Python code

// Obtain all function metrics for analysis
from FunctionMetrics functionMetrics
// Select each function along with its count of parameters without default values,
// sorted in descending order by this count to highlight functions with the most
// parameters requiring explicit values
select functionMetrics, 
       functionMetrics.getNumberOfParametersWithoutDefault() as paramsWithoutDefault 
order by paramsWithoutDefault desc