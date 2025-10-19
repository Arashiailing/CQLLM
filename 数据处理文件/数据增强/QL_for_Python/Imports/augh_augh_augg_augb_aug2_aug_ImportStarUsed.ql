/**
 * @name Wildcard Import Usage
 * @description Identifies Python files that use wildcard imports ('from ... import *'),
 *              which can cause namespace pollution and reduce code clarity.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis library for code examination capabilities
import python

// Retrieve all wildcard import statements using 'from ... import *' syntax
// These imports are represented by the ImportStar class in the Python AST
from ImportStar starImport

// Generate alerts for each detected wildcard import
// Each alert includes the import location and a descriptive message about potential issues
select starImport, "Wildcard imports ('from ... import *') may pollute namespaces and harm code maintainability."