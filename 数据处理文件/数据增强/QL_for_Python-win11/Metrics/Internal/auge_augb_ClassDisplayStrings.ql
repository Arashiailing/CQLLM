/**
 * @name Display strings of Python classes
 * @description Outputs all Python classes with their names formatted as display strings
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Identify every Python class in the codebase
from Class pyClass
// Generate output showing the class object and its name as display string
select pyClass, pyClass.getName()