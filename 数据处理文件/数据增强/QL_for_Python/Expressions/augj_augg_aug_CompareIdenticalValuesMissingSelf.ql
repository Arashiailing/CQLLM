/**
 * @name Potential missing 'self' reference in comparison
 * @description Detects locations in code where identical values are being compared,
 *              which typically suggests that the developer intended to compare an instance
 *              attribute with itself but forgot to include the 'self' reference.
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

// Import necessary modules for Python code analysis
import python

// Import module for detecting redundant or suspicious comparison expressions
import Expressions.RedundantComparison

// Query to find comparisons that might be missing 'self' reference
from RedundantComparison selfMissingComparison
// Filter to include only those comparisons that potentially lack 'self' reference
where selfMissingComparison.maybeMissingSelf()
// Output the problematic comparison with an appropriate warning message
select selfMissingComparison, "Comparison of identical values; may be missing 'self'."