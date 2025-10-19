/**
 * @name Comparison of identical values
 * @description Detects code locations where a comparison operation is performed between identical values.
 *              Such comparisons usually indicate unclear programming intentions or potential logical flaws.
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

import python  // Import Python library for analyzing Python code
import Expressions.RedundantComparison  // Import module for detecting redundant comparison expressions

// Find redundant comparison expressions
from RedundantComparison redundantValueComparison
// Apply filtering conditions
where 
  // Exclude constant comparisons
  not redundantValueComparison.isConstant() and 
  // Exclude comparisons that might be missing self
  not redundantValueComparison.maybeMissingSelf()
// Output qualifying comparison expressions with warning message
select redundantValueComparison, 
       "Comparison of identical values; use cmath.isnan() if testing for not-a-number."