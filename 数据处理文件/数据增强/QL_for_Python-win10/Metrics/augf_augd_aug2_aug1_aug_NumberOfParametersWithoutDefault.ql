/**
 * @name Count of non-default parameters
 * @description This analysis identifies Python functions containing parameters
 *              that do not have default values assigned. Functions with numerous
 *              non-default parameters often become harder to maintain and test,
 *              as they require more explicit arguments during invocation. By
 *              quantifying this metric, developers can pinpoint functions that
 *              may benefit from refactoring, such as introducing default values
 *              or parameter objects to improve code quality.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Provides static analysis capabilities for Python code

// Retrieve function metrics to analyze parameter patterns
from FunctionMetrics funcMetric
// For each function, calculate and display the count of parameters without default values
// Results are ordered from highest to lowest to prioritize functions needing attention
select funcMetric, 
       funcMetric.getNumberOfParametersWithoutDefault() as nonDefaultParamCount 
order by nonDefaultParamCount desc