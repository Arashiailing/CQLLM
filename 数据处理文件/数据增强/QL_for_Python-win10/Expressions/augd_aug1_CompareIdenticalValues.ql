/**
 * @name Comparison of identical values
 * @description Detects comparisons where identical values are compared,
 *              which may indicate unclear logic or potential errors.
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

// Import core modules for Python AST analysis and redundant expression detection
import python
import Expressions.RedundantComparison

// Identify redundant comparisons between identical values
from RedundantComparison redundantExpr
where 
    // Filter out constant comparisons (intentional test cases)
    not redundantExpr.isConstant()
    and
    // Exclude cases where 'self' reference might be missing
    not redundantExpr.maybeMissingSelf()
// Report findings with context-specific guidance
select redundantExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."