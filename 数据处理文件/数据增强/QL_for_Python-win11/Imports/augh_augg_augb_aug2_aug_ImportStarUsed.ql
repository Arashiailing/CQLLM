/**
 * @name Wildcard Import Usage
 * @description Detects Python files containing wildcard imports ('from ... import *'),
 *              which can lead to namespace pollution and reduced code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis library to enable code examination and analysis
import python

// Identify all wildcard import statements (using 'from ... import *' syntax) in the codebase
// The ImportStar class represents these specific types of import statements in the Python AST
from ImportStar wildcardImport

// Generate a report for each detected wildcard import statement
// The report includes the location of the import and a message explaining the potential issues
select wildcardImport, "Usage of 'from ... import *' may introduce namespace pollution and negatively impact code maintainability."