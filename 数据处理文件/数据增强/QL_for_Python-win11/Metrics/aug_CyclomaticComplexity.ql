/**
 * @name Cyclomatic complexity of functions
 * @description Calculates the cyclomatic complexity for each Python function. Cyclomatic complexity
 *              is a software metric that measures the number of linearly independent paths through
 *              a program's source code. Higher complexity values indicate more branching logic,
 *              which typically requires more test cases and may reduce maintainability.
 * @kind treemap
 * @id py/cyclomatic-complexity-per-function
 * @treemap.warnOn highValues
 * @metricType callable
 * @metricAggregate avg max sum
 * @tags testability
 *       complexity
 *       maintainability
 */

import python

// Extract function units and their corresponding cyclomatic complexity metrics
from Function callableUnit, int cyclomaticValue
// Match the complexity variable with the actual cyclomatic complexity calculation for each function
where cyclomaticValue = callableUnit.getMetrics().getCyclomaticComplexity()
// Present results showing each function alongside its complexity score, sorted from most to least complex
select callableUnit, cyclomaticValue order by cyclomaticValue desc