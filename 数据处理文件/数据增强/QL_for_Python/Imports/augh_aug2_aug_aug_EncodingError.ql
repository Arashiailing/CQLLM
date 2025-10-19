/**
 * @name Encoding error
 * @description Identifies Python code with problematic character encoding configurations
 *              that may cause runtime exceptions and impede static analysis effectiveness.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all encoding-related configuration issues in the Python codebase
from EncodingError encodingDefect

// For each identified encoding configuration issue, retrieve its descriptive message
// and present the issue instance alongside its corresponding diagnostic message
select encodingDefect, encodingDefect.getMessage()