/**
 * @name Identical Value Comparison
 * @description Detects comparisons where both operands are identical, which may indicate unclear intent.
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

import python  // Import Python module for analyzing Python source code
import Expressions.RedundantComparison  // Import library for detecting redundant comparisons

// Identify redundant comparisons from the RedundantComparison class
from RedundantComparison redundantComparison
// Apply filters: exclude constant comparisons and those potentially missing 'self'
where 
  not redundantComparison.isConstant() and 
  not redundantComparison.maybeMissingSelf()
// Select matching comparisons and generate appropriate warning message
select 
  redundantComparison, 
  "Comparison of identical values; use cmath.isnan() if testing for not-a-number."