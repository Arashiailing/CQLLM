/**
 * @name Number of parameters without defaults
 * @description Detects and quantifies function parameters that are not assigned default values.
 *              Functions containing multiple parameters without defaults tend to be more difficult
 *              to test and maintain, potentially impacting code quality.
 * @kind treemap
 * @id py/number-of-parameters-without-default-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max
 * @tags testability
 *       complexity
 */

import python  // Essential module for performing static analysis on Python source code

// Extract function metrics from the analyzed Python codebase
from FunctionMetrics funcMetrics
// Compute the quantity of parameters lacking default values for each function
// This measurement serves as an indicator of function complexity and maintainability
select funcMetrics, 
       funcMetrics.getNumberOfParametersWithoutDefault() as paramWithoutDefaultCount 
// Sort the results in descending order based on the count of parameters without defaults
// This arrangement prioritizes functions that may require refactoring due to high complexity
order by paramWithoutDefaultCount desc