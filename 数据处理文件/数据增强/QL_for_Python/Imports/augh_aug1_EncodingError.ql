/**
 * @name Encoding error
 * @description Identifies encoding issues in Python code that may cause runtime exceptions
 *              and impede static analysis. These problems typically arise when text
 *              processing operations are performed without proper character encoding handling.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// This query detects all instances of encoding problems throughout the codebase
// and retrieves their corresponding diagnostic messages for reporting purposes
from EncodingError encodingDefect
select encodingDefect, encodingDefect.getMessage()