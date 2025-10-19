/**
 * @name Encoding error
 * @description Identifies encoding issues in code that may trigger runtime exceptions and impede code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Retrieve all encoding error instances and their associated messages
from EncodingError encodingError
select encodingError, encodingError.getMessage()