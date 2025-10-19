/**
 * @name Wildcard Import Usage
 * @description Detects Python source files containing wildcard imports ('from ... import *').
 *              This practice can lead to namespace pollution and make code harder to understand.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module to enable code inspection capabilities
import python

// Find all import statements that use the wildcard ('*') syntax
// The ImportStar class represents these statements in the Python abstract syntax tree
from ImportStar wildcardImport

// Create an alert for each identified wildcard import
// Each alert provides the import location and explains why this pattern is discouraged
select wildcardImport, "Wildcard imports ('from ... import *') can clutter namespaces and negatively impact code maintainability."