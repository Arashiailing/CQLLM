/**
 * @name Wildcard Import Usage
 * @description Detects Python files using wildcard imports ('from ... import *')
 *              which introduce namespace pollution and decrease code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import core Python analysis capabilities for code examination
import python

// Identify all wildcard import statements in the codebase
from ImportStar starImport
// Report each wildcard import with a descriptive message explaining the risks
select starImport, "Wildcard imports ('from ... import *') pollute the namespace and reduce code clarity, increasing maintenance difficulty."