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

from Import stmt
where 
  // Verify the import statement contains multiple module names
  count(stmt.getAName()) > 1
  // Exclude "from ... import ..." style imports
  and not stmt.isFromImport()
select stmt, "Multiple imports on one line."