/**
 * @name Multiple imports on one line
 * @description Detects import statements violating PEP8 by importing
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

from Import stmt
where 
  // Exclude 'from ... import ...' statements to focus on regular imports
  not stmt.isFromImport()
  // Validate import statement contains multiple module names
  and exists(int n | n = count(stmt.getAName()) and n > 1)
select stmt, "Multiple imports on one line."