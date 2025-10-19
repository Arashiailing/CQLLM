/**
 * @name Comparison of identical values
 * @description Identifies redundant comparisons where a value is compared to itself,
 *              which typically indicates a logical error or unclear intent.
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

import python  // Core Python library for code analysis
import Expressions.RedundantComparison  // Module for detecting redundant comparison expressions

// Main query to identify redundant value comparisons
from RedundantComparison redundantExpr
// Apply filtering conditions to reduce false positives:
where 
  // Exclude constant comparisons which may be intentional design choices
  not redundantExpr.isConstant() and 
  // Exclude cases where 'self' might be missing to prevent false alarms
  not redundantExpr.maybeMissingSelf()
// Generate results with appropriate warning message
select redundantExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."