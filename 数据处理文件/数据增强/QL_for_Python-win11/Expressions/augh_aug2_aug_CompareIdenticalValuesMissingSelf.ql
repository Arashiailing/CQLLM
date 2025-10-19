/**
 * @name Possible absence of 'self' in comparison operations
 * @description Detects comparisons between identical values that may indicate
 *              an omitted 'self' reference in object-oriented Python code.
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

import python
import Expressions.RedundantComparison

from RedundantComparison redundantComp
where redundantComp.maybeMissingSelf()
select redundantComp, "Comparison of identical values; may be missing 'self'."