/**
 * @name Encoding error
 * @description Identifies encoding issues in Python code that may cause runtime failures
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

// Define source for encoding-related problems in Python code
from EncodingError encodingProblem

// Report identified encoding problems with their descriptive messages
select encodingProblem, encodingProblem.getMessage()