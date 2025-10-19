/**
 * @name Potential missing 'self' reference in comparison
 * @description Detects comparisons of identical values in class methods that might be missing a 'self' reference.
 *              Such comparisons typically lead to logical errors, causing conditions to always evaluate to true or false.
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

import python  // Provides static analysis capabilities for Python code
import Expressions.RedundantComparison  // Enables detection of potentially problematic comparison operations

from RedundantComparison suspectComparison  // Identifies comparison expressions that might be missing 'self' reference
where suspectComparison.maybeMissingSelf()  // Filters for comparisons that potentially lack 'self' reference
select suspectComparison, "Comparison of identical values; may be missing 'self'."  // Outputs the problematic comparison with a warning message