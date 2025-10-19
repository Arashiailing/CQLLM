/**
 * @name Encoding error
 * @description Identifies Python encoding issues that may lead to runtime failures
 *              and impede static analysis effectiveness.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Capture all encoding-related violations in the codebase
// For each identified violation, extract its diagnostic message
// and report the violation location with corresponding details
from EncodingError encodingIssue

select encodingIssue,
       encodingIssue.getMessage()