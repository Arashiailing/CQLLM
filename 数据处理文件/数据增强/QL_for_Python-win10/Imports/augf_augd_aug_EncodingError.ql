/**
 * @name Encoding error
 * @description Identifies Python encoding issues that may cause runtime failures
 *              and impede static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// This query detects encoding violations in Python source code
// and outputs them with detailed diagnostic information.

// Find all occurrences of encoding-related issues
from EncodingError encodingIssue

// Present the identified encoding problems with their messages
select encodingIssue, encodingIssue.getMessage()