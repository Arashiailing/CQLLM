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

// Query to detect non-constant self-comparisons excluding false positives
from RedundantComparison redundantComp
where 
  // Exclude constant comparisons (e.g., 5 == 5) as they're intentional
  not redundantComp.isConstant() 
  // Exclude cases potentially caused by missing 'self' references
  and not redundantComp.maybeMissingSelf()
// Report redundant comparison with NaN handling suggestion
select redundantComp, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."