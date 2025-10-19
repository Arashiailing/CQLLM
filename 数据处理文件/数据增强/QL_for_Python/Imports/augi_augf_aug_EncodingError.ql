/**
 * @name Encoding issue
 * @description Identifies encoding-related problems in Python code that can cause runtime failures
 *              and impede static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Locate all encoding-related issues in the codebase
from EncodingError encodingIssue
// Report each issue with its location and diagnostic message
select encodingIssue, encodingIssue.getMessage()