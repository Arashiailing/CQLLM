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

// Detects import statements violating PEP 8's one-import-per-line guideline
// Focuses exclusively on standard imports (not 'from ... import ...' syntax)
// that combine multiple module imports in a single statement
from Import importStmt
where 
    // Exclude 'from ... import ...' style imports
    not importStmt.isFromImport()
    // Identify statements importing multiple modules
    and count(importStmt.getAName()) > 1
select importStmt, "Multiple imports on one line."