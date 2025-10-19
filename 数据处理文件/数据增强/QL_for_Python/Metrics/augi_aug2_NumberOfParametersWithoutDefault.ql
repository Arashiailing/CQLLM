/**
 * @name Number of parameters without defaults
 * @description This query identifies functions by counting their parameters that do not have default values.
 *              Functions with a high number of parameters without defaults can be challenging to test
 *              and maintain, which might suggest a need for refactoring or a design review.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python library for analyzing Python source code

// Define the source for our analysis: function metrics from the Python codebase
from FunctionMetrics funcMetrics
// Select the function metrics and calculate the count of parameters without default values
select 
    funcMetrics, 
    funcMetrics.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
// Order the results by the count of non-default parameters in descending order
// to highlight functions with the most parameters requiring explicit values
order by nonDefaultParamCount desc