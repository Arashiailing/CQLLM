/**
 * @name Detection of Comparisons Between Identical Values
 * @description Identifies code locations where identical values are compared,
 *              which may indicate logical errors or programming mistakes.
 * @kind problem
 * @tags reliability
 *       correctness
 *       readability
 *       convention
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/comparison-of-identical-expressions
 */

// Import Python analysis modules
import python
import Expressions.RedundantComparison

// Main query: Detect redundant comparisons between identical values
from RedundantComparison redundantComparison
where 
    // Exclude comparisons that are intentionally constant (e.g., for testing)
    not redundantComparison.isConstant()
    // Exclude cases where the comparison might be due to a missing 'self' reference
    and not redundantComparison.maybeMissingSelf()
// Output the identified comparison with a remediation message
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."