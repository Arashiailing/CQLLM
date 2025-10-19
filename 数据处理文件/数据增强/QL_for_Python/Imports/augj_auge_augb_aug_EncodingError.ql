/**
 * @name Encoding error
 * @description Detects Python source files with invalid encoding declarations that can
 *              lead to runtime failures and hinder static analysis capabilities. This
 *              query identifies encoding declarations that do not conform to Python's
 *              strict syntax requirements.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all Python files containing encoding declaration violations
from EncodingError encodingIssue

// Generate diagnostic report for each detected encoding violation
select encodingIssue, encodingIssue.getMessage()