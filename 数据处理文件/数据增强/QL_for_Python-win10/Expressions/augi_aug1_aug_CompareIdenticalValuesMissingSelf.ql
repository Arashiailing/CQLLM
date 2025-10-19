/**
 * @name Potential missing 'self' reference in comparison
 * @description Identifies comparisons between identical values, potentially indicating a forgotten 'self' reference.
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
import Expressions.RedundantComparison  // Enables detection of comparison operations that might be logically flawed

from RedundantComparison redundantComp  // Selects redundant comparison expressions that could be missing 'self'
where redundantComp.maybeMissingSelf()  // Filters for comparisons that likely lack a 'self' reference, resulting in identical value checks
select redundantComp, "Comparison of identical values; may be missing 'self'."  // Outputs the suspicious comparison with a warning about potential missing 'self'