/**
 * @name Encoding issue
 * @description Identifies encoding-related problems in Python code that can cause runtime failures
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

// Identify all instances of encoding problems in the codebase
from EncodingError encodingProblem
// Output the encoding problem along with its detailed message
select encodingProblem, encodingProblem.getMessage()