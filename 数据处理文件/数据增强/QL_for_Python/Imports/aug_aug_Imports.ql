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

// Identify import statements that violate PEP 8's one-import-per-line guideline
// by importing multiple modules on a single line (excluding 'from ... import ...' style)
from Import stmt
where 
    // Count imported modules and verify multiple modules exist
    count(stmt.getAName()) > 1 and
    // Exclude 'from ... import ...' constructs
    not stmt.isFromImport()
select stmt, "Multiple imports on one line."