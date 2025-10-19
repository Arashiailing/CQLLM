/**
 * @name Encoding error
 * @description Detects Python code with flawed character encoding configurations
 *              that may trigger runtime exceptions and compromise static analysis accuracy.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Identify all occurrences of encoding configuration flaws
from EncodingError encodingFlaw

// Output results including each encoding flaw and its diagnostic message
select 
  encodingFlaw, 
  encodingFlaw.getMessage()