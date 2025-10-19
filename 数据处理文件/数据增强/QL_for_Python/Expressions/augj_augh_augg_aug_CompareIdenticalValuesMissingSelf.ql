/**
 * @name Missing 'self' reference in comparison operations
 * @description Identifies code locations where identical values are compared,
 *              indicating potential developer intent to compare an instance attribute
 *              with 'self' but omitted the 'self' qualifier.
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

from RedundantComparison redundantComparison
where redundantComparison.maybeMissingSelf()
select redundantComparison, "Comparison of identical values; may be missing 'self'."