/**
 * @name Encoding error
 * @description Detects encoding errors that cause runtime failures and block code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Identify encoding issues and their diagnostic messages
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()