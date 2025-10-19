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

// Extract function metrics to analyze parameter definitions
from FunctionMetrics funcMetric
// Present results with functions and their respective counts of non-default parameters, sorted in descending order
select funcMetric, funcMetric.getNumberOfParametersWithoutDefault() as nonDefaultParamCount order by nonDefaultParamCount desc