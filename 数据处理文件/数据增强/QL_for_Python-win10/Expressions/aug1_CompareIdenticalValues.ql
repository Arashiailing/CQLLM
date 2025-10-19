/**
 * @name Comparison of identical values
 * @description Detects comparisons where identical values are compared,
 *              which may indicate unclear logic or potential errors.
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

// Import necessary modules for Python code analysis
import python
import Expressions.RedundantComparison

// Define the main query to find redundant comparisons
from RedundantComparison redundantComparisonExpr
where 
    // Exclude constant comparisons which may be intentional
    not redundantComparisonExpr.isConstant() and
    // Exclude cases where 'self' might be missing
    not redundantComparisonExpr.maybeMissingSelf()
// Select the identified redundant comparisons with an appropriate warning message
select redundantComparisonExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."