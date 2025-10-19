/**
 * @name Comparison of identical values
 * @description Identifies logical flaws where values are compared against themselves,
 *              which always evaluate to true/false. Such comparisons typically indicate
 *              programming errors or ambiguous intentions. For NaN verification,
 *              use cmath.isnan() instead.
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

import python  // Core Python library for code analysis
import Expressions.RedundantComparison  // Module for detecting redundant comparison expressions

// Main detection logic for problematic self-comparisons
from RedundantComparison redundantComparison
where 
  // Filter out intentional constant comparisons
  not redundantComparison.isConstant() and
  // Exclude cases where 'self' might be missing to reduce false positives
  not redundantComparison.maybeMissingSelf()
// Report findings with remediation guidance
select redundantComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."