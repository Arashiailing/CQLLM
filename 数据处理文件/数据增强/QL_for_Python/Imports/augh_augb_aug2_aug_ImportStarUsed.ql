/**
 * @name Wildcard Import Usage
 * @description Detects Python files containing wildcard imports ('from ... import *')
 *              that may lead to namespace pollution and decreased code readability.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision medium
 * @id py/import-star-used
 */

// Import the Python analysis module for code examination
import python

// Identify all wildcard import statements in the codebase
from ImportStar starImport
// Report each wildcard import with a descriptive message
select starImport, "Wildcard imports ('from ... import *') can pollute the namespace and reduce code clarity, making maintenance more difficult."