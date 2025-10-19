/**
 * @name Python Class Display Strings
 * @description Discovers and lists all Python classes throughout the codebase, 
 *              displaying their names as formatted strings for easy identification.
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Retrieve all Python class definitions present in the analyzed codebase
from Class pythonClass

// Present each class entity along with its corresponding name as a display string
select pythonClass, pythonClass.getName()