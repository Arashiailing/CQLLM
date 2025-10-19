/**
 * @name Comparison of identical values
 * @description Detects redundant comparisons where a value is compared to itself.
 *              These comparisons often indicate unclear logic or potential errors.
 *              For NaN checks, use cmath.isnan() instead of direct comparisons.
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

import python
import Expressions.RedundantComparison

// Find redundant comparisons while excluding intentional cases
from RedundantComparison identicalComparison
where 
    // Exclude constant comparisons (likely intentional)
    not identicalComparison.isConstant() and
    // Avoid cases where 'self' might be missing in method calls
    not identicalComparison.maybeMissingSelf()
// Output identified issues with remediation guidance
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."