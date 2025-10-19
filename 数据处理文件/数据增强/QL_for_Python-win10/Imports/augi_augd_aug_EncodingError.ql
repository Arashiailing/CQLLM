/**
 * @name Encoding error
 * @description Detects Python encoding errors that could lead to runtime failures and hinder static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Scan Python source code for encoding-related violations
from EncodingError encodingIssue

// Generate diagnostic report for each identified encoding issue
select encodingIssue, encodingIssue.getMessage()