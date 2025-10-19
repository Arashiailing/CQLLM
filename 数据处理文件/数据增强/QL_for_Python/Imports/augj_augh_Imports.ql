/**
 * @name Multiple imports on one line
 * @description Placing multiple import statements on a single line reduces code readability;
 *              PEP8 recommends that imports should typically be on separate lines.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/multiple-imports-on-line
 */

// Import the Python module for code analysis
import python

// This query detects import statements violating PEP8's one-import-per-line rule
// by identifying lines importing multiple modules simultaneously (e.g., "import modA, modB")
from Import problematicImport
where 
    // Verify the import contains multiple module names
    count(problematicImport.getAName()) > 1 and
    // Exclude "from ... import ..." style imports
    not problematicImport.isFromImport()
select problematicImport, "Multiple imports on one line."