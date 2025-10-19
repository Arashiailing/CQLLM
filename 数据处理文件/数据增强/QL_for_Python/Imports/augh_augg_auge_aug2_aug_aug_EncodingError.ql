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

// Identify all encoding configuration issues
from EncodingError encodingConfigIssue

// Report each issue with its diagnostic message
select 
  encodingConfigIssue, 
  encodingConfigIssue.getMessage()