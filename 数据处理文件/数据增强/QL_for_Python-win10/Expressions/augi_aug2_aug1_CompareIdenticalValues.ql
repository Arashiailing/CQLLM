/**
 * @name Identical Value Comparison Detection
 * @description Detects comparisons where the same value is compared against itself,
 *              which often indicates unclear logic, potential errors, or redundant code.
 *              Such comparisons typically always evaluate to the same result.
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

// Import necessary modules for Python static analysis
import python
import Expressions.RedundantComparison

// Find all redundant comparisons where identical values are being compared
from RedundantComparison identicalComparison
where 
    // Exclude constant comparisons as they may be intentionally designed
    // for testing or documentation purposes
    not identicalComparison.isConstant()
    // Filter out cases where the comparison might be due to a missing 'self'
    // reference in class methods, which is a common Python pattern
    and not identicalComparison.maybeMissingSelf()
// Report the identified redundant comparisons with helpful guidance
select identicalComparison, "Comparison of identical values detected. Consider using cmath.isnan() if testing for not-a-number values."