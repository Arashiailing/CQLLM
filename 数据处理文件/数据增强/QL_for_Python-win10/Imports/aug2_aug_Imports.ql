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

/*
 * This query identifies import statements that violate PEP8 by importing
 * multiple modules in a single line (e.g., "import modA, modB").
 * Such imports reduce code readability and maintainability.
 */

import python

from Import multiImportStmt
where 
  // Exclude "from ... import ..." style imports first
  not multiImportStmt.isFromImport() and
  // Then check for multiple module names in the import statement
  count(multiImportStmt.getAName()) > 1
select multiImportStmt, "Multiple imports on one line."