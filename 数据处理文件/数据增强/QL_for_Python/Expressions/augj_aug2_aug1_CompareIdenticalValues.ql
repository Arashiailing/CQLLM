/**
 * @name Comparison of identical values
 * @description Identifies comparisons where identical values are compared,
 *              which could indicate unclear logic or potential errors.
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
 * @id py/comparison-of-identical-expressions */

// Import core Python analysis modules and redundant comparison detection
import python
import Expressions.RedundantComparison

// Identify redundant comparisons between identical values
from RedundantComparison redundantComparison
where 
    // Exclude constant comparisons which may be intentionally designed
    not redundantComparison.isConstant()
    // Exclude cases where 'self' might be missing from attribute references
    and not redundantComparison.maybeMissingSelf()
// Report findings with remediation guidance
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."