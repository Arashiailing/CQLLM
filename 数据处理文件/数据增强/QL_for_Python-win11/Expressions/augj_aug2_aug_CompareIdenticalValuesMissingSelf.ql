/**
 * @name Possible absence of 'self' in comparison operations
 * @description Detects comparisons between identical values that may indicate 
 *              a missing 'self' reference in object-oriented Python code.
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

import python  // Core Python static analysis capabilities
import Expressions.RedundantComparison  // Identifies potentially problematic comparisons

from RedundantComparison suspectComparison
where suspectComparison.maybeMissingSelf()
select suspectComparison, "Identical value comparison; potential missing 'self' reference."