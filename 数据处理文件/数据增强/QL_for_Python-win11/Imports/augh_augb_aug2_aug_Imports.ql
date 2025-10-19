/**
 * @name Multiple imports on one line
 * @description Identifies import statements that import multiple modules on a single line,
 *              which contradicts PEP8's recommendation for placing imports on separate lines.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-one-line
 */

/*
 * This query targets import statements that import multiple modules in a single line
 * (e.g., "import modA, modB"). According to PEP8, imports should typically be on separate
 * lines to enhance code readability and maintainability.
 */

import python

from Import stmt
where 
  // Exclude "from ... import ..." style imports
  not stmt.isFromImport()
  // Check if the import statement contains multiple module names
  and count(stmt.getAName()) > 1
select stmt, "Multiple imports on one line."