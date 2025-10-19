/**
 * @name Encoding error
 * @description Identifies encoding errors causing runtime failures and blocking code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Detect encoding defects and retrieve their diagnostic messages
from EncodingError encodingDefect
select 
  encodingDefect, 
  encodingDefect.getMessage()