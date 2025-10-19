/**
 * @name Encoding error
 * @description This query detects encoding issues that can cause runtime failures
 * and prevent proper code analysis.
 * @id py/encoding-error
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify encoding problems in the codebase
// Each encoding issue is captured along with its corresponding error message
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()