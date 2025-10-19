/**
 * @name Identical value comparison detection
 * @description Identifies comparisons between identical expressions that suggest
 *              unclear logic, potential errors, or unnecessary code patterns.
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

// Core analysis modules for Python
import python
import Expressions.RedundantComparison

// Primary analysis target
from RedundantComparison problematicComparison
where 
    // Exclude cases where 'self' might be missing in attribute references
    not problematicComparison.maybeMissingSelf()
    // Filter out intentional constant comparisons
    and not problematicComparison.isConstant()
// Report findings with actionable guidance
select problematicComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."