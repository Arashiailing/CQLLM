/**
 * @name Identical value comparison detection
 * @description Detects comparisons between identical values that may indicate
 *              unclear logic, potential errors, or redundant code patterns.
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
from RedundantComparison redundantExpr
where 
    // First condition: exclude cases where 'self' might be missing from attribute references
    not redundantExpr.maybeMissingSelf()
    // Second condition: filter out constant comparisons which may be intentionally designed
    and not redundantExpr.isConstant()
// Report identified redundant comparisons with appropriate guidance
select redundantExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."