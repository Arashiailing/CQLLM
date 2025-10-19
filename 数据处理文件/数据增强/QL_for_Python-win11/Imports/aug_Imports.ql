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

from Import importStatement
where 
  // Check if the import statement contains multiple module names
  count(importStatement.getAName()) > 1 and
  // Exclude "from ... import ..." style imports
  not importStatement.isFromImport()
select importStatement, "Multiple imports on one line."