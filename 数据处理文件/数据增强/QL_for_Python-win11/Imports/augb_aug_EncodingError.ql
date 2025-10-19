/**
 * @name Encoding error
 * @description Identifies encoding issues in Python code that may cause runtime failures
 *              and impede static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all encoding error instances
from EncodingError encodingError

// Output encoding errors with detailed messages
select encodingError, encodingError.getMessage()