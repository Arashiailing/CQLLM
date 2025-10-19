/**
 * @name Encoding error
 * @description Identifies Python code containing flawed character encoding configurations 
 *              that may trigger runtime failures and obstruct static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Locate all encoding configuration issues in the Python codebase
// and prepare their corresponding diagnostic messages
from EncodingError issue
select issue, issue.getMessage()