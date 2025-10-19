/**
 * @name Count of non-default parameters
 * @description This query analyzes Python functions to count parameters that lack
 *              default values. Higher counts indicate functions that may be
 *              less flexible and harder to test.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python

// Retrieve all function metrics from the codebase for parameter analysis
from FunctionMetrics funcMetric
// Calculate and display the count of non-default parameters for each function,
// sorted in descending order to highlight functions with the most required parameters
select funcMetric,
       funcMetric.getNumberOfParametersWithoutDefault() as nonDefaultParamCount
order by nonDefaultParamCount desc