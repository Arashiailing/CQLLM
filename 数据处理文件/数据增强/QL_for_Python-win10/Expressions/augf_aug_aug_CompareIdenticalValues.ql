/**
 * @name Identical Value Comparison
 * @description Detects comparisons where a value is compared against itself,
 *              which usually represents a logical mistake or ambiguous code intention.
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

// Define the main query to find identical value comparisons
from RedundantComparison identicalComparison

// Apply filters to reduce false positives
where 
  // Filter out constant comparisons which could be intentional
  not identicalComparison.isConstant() and 
  // Filter out cases where 'self' might be missing to avoid false alarms
  not identicalComparison.maybeMissingSelf()

// Output the results with an appropriate warning message
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."