/**
 * @name Encoding error
 * @description Identifies encoding-related issues that lead to runtime failures and obstruct code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Identify encoding issues and extract diagnostic messages
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()