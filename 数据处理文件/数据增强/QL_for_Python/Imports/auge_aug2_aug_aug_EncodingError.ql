/**
 * @name Encoding error
 * @description Identifies Python code containing improper character encoding configurations
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

// Identify all encoding violations in the Python codebase
from EncodingError encodingViolation

// Extract the descriptive message for each identified encoding violation
// and present it alongside the violation instance
select 
  encodingViolation, 
  encodingViolation.getMessage()