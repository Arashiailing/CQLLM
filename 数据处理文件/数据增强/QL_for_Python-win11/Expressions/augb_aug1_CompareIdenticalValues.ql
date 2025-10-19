/**
 * @name Identical Value Comparison Detection
 * @description Identifies code locations where identical values are being compared,
 *              which could suggest logical confusion or potential programming mistakes.
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

// Main query to detect redundant comparisons in Python code
from RedundantComparison identicalValueComparison
where 
    // Exclude intentional constant comparisons
    not identicalValueComparison.isConstant()
    // Exclude cases where 'self' might be missing
    and not identicalValueComparison.maybeMissingSelf()
// Output the identified redundant comparisons with a relevant warning message
select identicalValueComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."