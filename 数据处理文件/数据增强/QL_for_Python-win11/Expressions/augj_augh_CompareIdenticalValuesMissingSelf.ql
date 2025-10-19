/**
 * @name Potentially missing 'self' parameter in comparison
 * @description Identifies Python code patterns where identical values are being compared,
 *              which often suggests that the developer intended to compare an instance
 *              variable with another value but forgot to include the 'self' parameter.
 *              Such comparisons are logically redundant and may lead to unexpected program behavior.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/comparison-missing-self
 */

import python
import Expressions.RedundantComparison

// Find all redundant comparisons that might be missing 'self'
from RedundantComparison potentialMissingSelfComparison
// Filter for comparisons where the developer likely forgot to include 'self'
where potentialMissingSelfComparison.maybeMissingSelf()
// Report the comparison with a warning message
select potentialMissingSelfComparison, "Comparison of identical values; may be missing 'self'."