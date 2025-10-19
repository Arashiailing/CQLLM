/**
 * @name Encoding error
 * @description Identifies encoding issues in code that can lead to runtime exceptions
 *              and hinder code analysis.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/encoding-error
 */

import python

// Retrieve all instances of encoding errors and their associated messages
from EncodingError encodingDefect
select encodingDefect, encodingDefect.getMessage()