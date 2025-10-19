/**
 * @name Potential missing 'self' reference in comparisons
 * @description Detects comparison operations between identical values, which may suggest a forgotten 'self' reference.
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

import python  // Module providing static analysis capabilities for Python source code
import Expressions.RedundantComparison  // Expression analysis module for identifying logically flawed comparison operations

from RedundantComparison selfMissingComparison  // Filter comparisons that might be missing a 'self' reference
where selfMissingComparison.maybeMissingSelf()  // Condition: comparison operation likely compares identical values due to missing 'self'
select selfMissingComparison, "Identical values compared; possibly missing 'self' reference."  // Output suspicious comparison and warning message