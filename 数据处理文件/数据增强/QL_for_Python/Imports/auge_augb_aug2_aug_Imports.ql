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
 * This query detects import statements that violate PEP8 guidelines by importing
 * multiple modules within a single line (e.g., "import modA, modB").
 * Such practice negatively impacts code readability and maintainability.
 */

import python

from Import multiModuleImport
where 
  // First, ensure we're dealing with a regular import statement
  not multiModuleImport.isFromImport()
  // Then, verify that multiple modules are being imported
  and count(multiModuleImport.getAName()) > 1
select multiModuleImport, "Multiple imports on one line."