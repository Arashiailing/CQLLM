/**
 * @name Multiple imports on one line
 * @description Defining multiple imports on one line makes code more difficult to read;
 *              PEP8 states that imports should usually be on separate lines.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

import python

// This query identifies import statements that violate PEP 8's one-import-per-line guideline.
// It specifically targets standard import statements (not 'from ... import ...' style)
// that import multiple modules on a single line.
from Import multiLineImport
where 
    // First, ensure we're only looking at standard import statements
    not multiLineImport.isFromImport()
    // Then, check if the statement imports multiple modules
    and 
    // Count the number of imported modules in the statement
    count(multiLineImport.getAName()) > 1
select multiLineImport, "Multiple imports on one line."