/**
 * @name Multiple imports on one line
 * @description Detects import statements that violate PEP8 by importing
 *              multiple modules in a single line (e.g., "import modA, modB").
 *              Such imports reduce code readability and maintainability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

import python

from Import importDeclaration
where 
  // Ensure we're only checking regular import statements (not 'from ... import ...')
  not importDeclaration.isFromImport()
  // Verify that the import statement includes multiple modules
  and count(importDeclaration.getAName()) > 1
select importDeclaration, "Multiple imports on one line."