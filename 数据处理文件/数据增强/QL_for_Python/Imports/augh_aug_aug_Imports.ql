/**
 * @name Multiple imports on one line
 * @description Detects Python import statements that violate PEP 8's recommendation
 *              of placing each import on a separate line. Multiple imports on a single
 *              line reduce code readability and maintainability.
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
// Specifically, it targets statements that import multiple modules on a single line,
// while excluding 'from ... import ...' style imports which follow a different pattern.
from Import importStmt
where 
    // Condition 1: The import statement contains multiple modules
    count(importStmt.getAName()) > 1
    // Condition 2: The import is not of the 'from ... import ...' style
    and not importStmt.isFromImport()
select importStmt, "Multiple imports on one line."