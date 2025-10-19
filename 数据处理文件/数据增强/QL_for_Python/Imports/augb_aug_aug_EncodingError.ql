/**
 * @name Encoding error
 * @description Detects Python encoding issues that may cause runtime failures
 *              and hinder static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Locate all encoding violations present in the codebase
from EncodingError encodingIssue

// For each violation, retrieve its detailed diagnostic message
// and present it together with the violation instance
select encodingIssue, encodingIssue.getMessage()