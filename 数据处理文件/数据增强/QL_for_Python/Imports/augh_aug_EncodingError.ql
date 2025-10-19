/**
 * @name Encoding error
 * @description Identifies Python code with encoding issues that may cause runtime failures
 *              and impede static analysis capabilities.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all Python encoding error instances
from EncodingError encodingError

// Output each encoding error with its diagnostic message
select encodingError, encodingError.getMessage()