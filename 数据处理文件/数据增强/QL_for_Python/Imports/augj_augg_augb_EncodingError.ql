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

// Locate encoding-related flaws and extract their diagnostic information
from EncodingError encodingIssue
select encodingIssue, encodingIssue.getMessage()