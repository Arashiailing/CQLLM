/**
 * @name Character Encoding Misconfiguration
 * @description Identifies Python source code containing improper character encoding settings
 *              that may result in runtime failures and impede static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Scan the Python codebase to detect all instances of encoding misconfigurations
// These issues can cause runtime exceptions and negatively impact static analysis
from EncodingError encodingIssue

// For each detected encoding issue, retrieve its detailed error message
// and present both the issue instance and message in the query results
select encodingIssue, encodingIssue.getMessage()