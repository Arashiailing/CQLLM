/**
 * @name Identical value comparison detection
 * @description Identifies comparisons where values are the same, which may indicate unclear intent.
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

// Define source for redundant comparison expressions
from RedundantComparison redundantExpr

// Apply filtering conditions to reduce false positives
where 
  // Exclude comparisons involving constant values
  not redundantExpr.isConstant() 
  // Exclude cases where 'self' reference might be missing
  and not redundantExpr.maybeMissingSelf()

// Generate results with appropriate warning message
select redundantExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."