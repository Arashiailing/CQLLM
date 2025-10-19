/**
 * @name Identical Value Comparison
 * @description Identifies redundant comparisons where both operands are identical,
 *              which may indicate unclear programming intent or logical errors.
 *              This check excludes constant expressions and potential missing self references.
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

from RedundantComparison redundantExpr
where 
  /* Exclude constant expressions from analysis */
  not redundantExpr.isConstant() 
  /* Filter out cases where 'self' might be missing */
  and not redundantExpr.maybeMissingSelf()
select 
  redundantExpr, 
  "Comparison of identical values detected; consider using cmath.isnan() for NaN checks."