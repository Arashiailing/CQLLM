/**
 * @name Number of parameters without defaults
 * @description Counts parameters in functions that lack default value definitions.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Import the Python library for analyzing Python code

// Select functions from FunctionMetrics class and calculate the number of parameters without default values
from FunctionMetrics functionMetric
select functionMetric, functionMetric.getNumberOfParametersWithoutDefault() as paramCountWithoutDefault order by paramCountWithoutDefault desc
// Output the function and its count of parameters without default values, sorted in descending order