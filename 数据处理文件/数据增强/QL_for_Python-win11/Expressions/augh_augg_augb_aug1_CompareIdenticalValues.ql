/**
 * @name Identical Value Comparison Detection
 * @description Identifies locations where identical values are compared,
 *              indicating potential logical errors or programming mistakes.
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
from RedundantComparison identicalComparison
where 
    // Exclude intentional constant comparisons
    not identicalComparison.isConstant()
    // Exclude cases potentially missing 'self' references
    and not identicalComparison.maybeMissingSelf()
// Output identified comparisons with remediation guidance
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."