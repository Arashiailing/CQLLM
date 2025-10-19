/**
 * @name Comparison of identical values
 * @description Identifies redundant comparisons where a value is compared against itself.
 *              Such comparisons typically indicate unclear logic or potential errors.
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

// Identify redundant comparisons while excluding intentional cases
from RedundantComparison redundantComp
where 
    // Skip constant comparisons (likely intentional)
    not redundantComp.isConstant() and
    // Avoid cases where 'self' might be missing in method calls
    not redundantComp.maybeMissingSelf()
// Output identified issues with remediation guidance
select redundantComp, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."