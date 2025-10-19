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

// Retrieve all instances of encoding configuration issues
from EncodingError encodingIssue

// Generate results containing each encoding issue and its diagnostic message
select 
  encodingIssue, 
  encodingIssue.getMessage()