/**
 * @name Encoding error
 * @description Identifies encoding issues in Python code that may lead to runtime failures
 *              and impede static analysis capabilities. These errors typically occur when
 *              text encoding/decoding operations are improperly handled.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all instances of encoding-related problems in the codebase
from EncodingError encodingDefect

// Report each encoding defect along with its detailed diagnostic message
select encodingDefect, encodingDefect.getMessage()