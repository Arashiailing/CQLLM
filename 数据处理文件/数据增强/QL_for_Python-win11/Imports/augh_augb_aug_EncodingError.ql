/**
 * @name Encoding error
 * @description Detects Python source code encoding problems that could lead to
 *              runtime exceptions and interfere with static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Find all occurrences of encoding errors in the codebase
from EncodingError encodingIssue

// Report each encoding error with its corresponding diagnostic message
select encodingIssue, encodingIssue.getMessage()