/**
 * @name Encoding error
 * @description Identifies Python code with incorrect character encoding configurations
 *              that may trigger runtime exceptions and obstruct static analysis.
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
from EncodingError encodingProblem

// Extract the diagnostic message for each encoding problem
// and present it alongside the problem instance
select encodingProblem, encodingProblem.getMessage()