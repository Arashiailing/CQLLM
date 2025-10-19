/**
 * @name Number of parameters without defaults
 * @description Measures the quantity of function parameters that do not have default values.
 *              Callables with numerous parameters lacking defaults might be difficult to test
 *              and comprehend, possibly suggesting a design problem.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import Python library for analyzing Python source code

// Analysis to identify functions and compute their parameters without default values
from FunctionMetrics callableMetric
select 
    callableMetric, 
    callableMetric.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by 
    nonDefaultParamCount desc
// Results display functions ordered by the count of parameters without defaults in descending order