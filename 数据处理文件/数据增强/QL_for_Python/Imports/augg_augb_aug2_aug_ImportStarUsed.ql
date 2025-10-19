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

// Import necessary Python analysis components for code examination
import python

// Identify all wildcard import statements in the codebase
from ImportStar starImport
// Report each instance of wildcard import with a descriptive message
select starImport, "Usage of 'from ... import *' may introduce namespace pollution and negatively impact code maintainability."