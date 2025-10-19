/**
 * @name Potential missing 'self' reference in comparison
 * @description Detects comparisons between identical values that may indicate a missing 'self' reference in class methods. Such comparisons often result in logical errors where the condition always evaluates to true or false.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/comparison-missing-self
 */

import python  // Provides access to Python syntax tree for static analysis
import Expressions.RedundantComparison  // Detects redundant comparison expressions

from RedundantComparison redundantExpr  // Source: redundant comparison expressions that might lack 'self'
where redundantExpr.maybeMissingSelf()  // Filter: expressions potentially missing 'self' reference
select redundantExpr, "Comparison of identical values; may be missing 'self'."  // Output: problematic expression and warning message