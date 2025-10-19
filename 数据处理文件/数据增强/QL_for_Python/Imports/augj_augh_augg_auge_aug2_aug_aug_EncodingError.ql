/**
 * @name Encoding error
 * @description Detects Python code with improper character encoding configurations
 *              that can lead to runtime exceptions and hinder static analysis.
 * @kind problem
 * @id py/encoding-error
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 */

import python

// Find all instances of encoding configuration issues
from EncodingError encodingIssue

// Output each issue along with its associated diagnostic message
select 
  encodingIssue, 
  encodingIssue.getMessage()