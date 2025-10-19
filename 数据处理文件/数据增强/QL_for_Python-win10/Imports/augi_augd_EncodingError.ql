/**
 * @name Encoding error detection
 * @description Identifies encoding issues in Python code that can cause runtime exceptions,
 *              disrupt normal program execution, and potentially impede comprehensive
 *              analysis by static analysis tools.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Identify all instances of encoding errors and retrieve their corresponding error messages
from EncodingError encodingDefect
select encodingDefect, encodingDefect.getMessage()