/**
 * @name Missing 'self' reference in comparison operations
 * @description Detects locations in code where identical values are being compared,
 *              suggesting that the developer likely intended to compare an instance attribute
 *              with 'self' but forgot to include the 'self' qualifier.
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

from RedundantComparison suspiciousComparison
where suspiciousComparison.maybeMissingSelf()
select suspiciousComparison, "Comparison of identical values; may be missing 'self'."