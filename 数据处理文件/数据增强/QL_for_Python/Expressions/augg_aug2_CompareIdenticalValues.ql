/**
 * @name Identical Value Comparison
 * @description Identifies comparisons where both operands are identical, which may indicate unclear intent or potential logic errors.
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

from RedundantComparison identicalComp
where 
  not identicalComp.isConstant() 
  and not identicalComp.maybeMissingSelf()
select 
  identicalComp, 
  "Comparison of identical values detected; consider using cmath.isnan() for NaN checks."