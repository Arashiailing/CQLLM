/**
 * @name Encoding error
 * @description Detects Python encoding issues that may cause runtime failures
 *              and interfere with static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Locate all Python encoding error instances
from EncodingError encodingIssue

// Report encoding errors with diagnostic messages
select encodingIssue, encodingIssue.getMessage()