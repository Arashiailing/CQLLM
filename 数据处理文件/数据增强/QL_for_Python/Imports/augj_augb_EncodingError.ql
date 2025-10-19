/**
 * @name Encoding error
 * @description Identifies encoding-related issues that trigger runtime failures and impede code analysis
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Detect encoding problems and retrieve their diagnostic details
from EncodingError encodingProblem
select encodingProblem, encodingProblem.getMessage()