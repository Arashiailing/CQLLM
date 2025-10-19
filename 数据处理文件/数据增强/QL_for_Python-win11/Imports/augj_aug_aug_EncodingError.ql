/**
 * @name Encoding error
 * @description Identifies encoding issues in Python code that may cause runtime failures
 *              and impede static analysis of the code.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// This query detects Python source files with encoding declarations that are either
// incorrect, missing, or incompatible with the actual content of the file. Such issues
// can cause runtime failures when the Python interpreter attempts to parse the file,
// and may also prevent static analysis tools from correctly understanding the code.
from EncodingError encodingIssue

// For each identified encoding issue, retrieve the corresponding error message
// to provide context about the problem and help developers understand and fix it.
select encodingIssue, encodingIssue.getMessage()