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
from RedundantComparison redundantComp
where 
    // Filter out intentional constant comparisons
    not redundantComp.isConstant()
    // Exclude cases involving potential missing 'self' references
    and not redundantComp.maybeMissingSelf()
// Output identified comparisons with remediation guidance
select redundantComp, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."