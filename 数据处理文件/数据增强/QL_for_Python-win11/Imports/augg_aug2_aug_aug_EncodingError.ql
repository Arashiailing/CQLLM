/**
 * @name Encoding error
 * @description Detects Python code with improper character encoding configurations 
 *              that could lead to runtime exceptions and hinder static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all encoding-related issues in the Python codebase
from EncodingError encodingProblem

// For each identified issue, retrieve its descriptive message
// and pair it with the corresponding issue instance for output
select encodingProblem, encodingProblem.getMessage()