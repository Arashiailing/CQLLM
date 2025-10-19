/**
 * @name Multiple imports on one line
 * @description This query identifies import statements that violate PEP 8's recommendation
 *              of placing each import on a separate line. Multiple imports on a single line
 *              reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

import python

// This query detects import statements that import multiple modules on a single line,
// which violates PEP 8's one-import-per-line guideline. Note that 'from ... import ...'
// style imports are excluded from this check as they follow different conventions.
from Import importDeclaration
where 
    // Check if the statement imports multiple modules
    count(importDeclaration.getAName()) > 1 and
    // Exclude 'from ... import ...' constructs
    not importDeclaration.isFromImport()
select importDeclaration, "Multiple imports on one line."