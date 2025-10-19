/**
 * @name Encoding error
 * @description Detects Python code with problematic character encoding configurations
 *              that could cause runtime failures and hinder static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Locate all encoding configuration issues in the Python codebase
from EncodingError encodingIssue

// Retrieve diagnostic details for each identified encoding issue
// and present them together with the issue instance
select encodingIssue, encodingIssue.getMessage()