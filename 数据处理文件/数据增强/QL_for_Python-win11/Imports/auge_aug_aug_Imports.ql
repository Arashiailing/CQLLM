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

// This query detects import statements that do not follow PEP 8's recommendation
// of having one import per line, specifically targeting statements that import
// multiple modules on a single line (excluding 'from ... import ...' syntax)
from Import importStatement
where 
    // Check if the import statement contains multiple modules
    count(importStatement.getAName()) > 1
    // Ensure it's not a 'from ... import ...' statement
    and not importStatement.isFromImport()
select importStatement, "Multiple imports on one line."