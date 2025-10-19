/**
 * @name Cyclomatic complexity of functions
 * @description Evaluates the cyclomatic complexity metric for Python functions. This metric quantifies
 *              the number of linearly independent paths through a function's code, reflecting its
 *              decision logic density. Elevated complexity values indicate increased branching,
 *              potentially demanding more rigorous testing efforts and impacting maintainability.
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

// Identify all Python functions and their corresponding complexity metrics
from Function analyzedFunction, int pathComplexity
// Determine cyclomatic complexity by analyzing function control flow
where pathComplexity = analyzedFunction.getMetrics().getCyclomaticComplexity()
// Output results with functions and their complexity scores, sorted highest complexity first
select analyzedFunction, pathComplexity order by pathComplexity desc