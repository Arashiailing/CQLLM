/**
 * @name Possible absence of 'self' in comparison operations
 * @description Identifies comparison expressions where identical values are compared,
 *              potentially indicating a missing 'self' reference in object-oriented code.
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

import python  // Provides static analysis capabilities for Python source code
import Expressions.RedundantComparison  // Enables detection of potentially problematic comparison operations

from RedundantComparison potentialMissingSelfComparison
where potentialMissingSelfComparison.maybeMissingSelf()
select potentialMissingSelfComparison, "Comparison of identical values; may be missing 'self'."