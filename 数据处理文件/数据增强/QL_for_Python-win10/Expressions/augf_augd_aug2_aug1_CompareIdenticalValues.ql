/**
 * @name Comparison of identical values
 * @description Detects comparisons between identical values, which may indicate
 *              unclear logic, potential errors, or missing NaN checks.
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

// Import required modules for Python code analysis
import python
import Expressions.RedundantComparison

// Identify redundant comparisons between identical values
from RedundantComparison redundantComp
where 
    // Filter out intentional constant comparisons
    not redundantComp.isConstant()
    // Exclude cases where 'self' might be missing from attribute references
    and not redundantComp.maybeMissingSelf()
// Report findings with remediation guidance
select redundantComp, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."