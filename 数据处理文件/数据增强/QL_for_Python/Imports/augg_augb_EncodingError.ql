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

// Find encoding defects and retrieve their diagnostic details
from EncodingError encodingDefect
select encodingDefect, encodingDefect.getMessage()