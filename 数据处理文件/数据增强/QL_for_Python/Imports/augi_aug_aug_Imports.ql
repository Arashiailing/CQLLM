/**
 * @name Multiple imports on one line
 * @description Detects import statements that define multiple modules on a single line,
 *              which violates PEP 8's recommendation of one import per line for better readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

import python

// Find import statements that don't follow PEP 8's one-import-per-line rule
// Specifically targeting statements like "import os, sys" rather than "from os import path"
from Import importStatement
where 
    // Verify that the statement imports multiple modules
    count(importStatement.getAName()) > 1 and
    // Exclude 'from ... import ...' style imports as they follow a different pattern
    not importStatement.isFromImport()
select importStatement, "Multiple imports on one line."