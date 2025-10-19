/**
 * @name Display Python class names
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 * @description Shows all Python classes in the codebase along with their names.
 *              Useful for analyzing the class hierarchy and structure of a Python project.
 */

import python

// Source: All Python classes in the codebase
from Class pythonClass

// Output: The class object and its name
select pythonClass, pythonClass.getName()