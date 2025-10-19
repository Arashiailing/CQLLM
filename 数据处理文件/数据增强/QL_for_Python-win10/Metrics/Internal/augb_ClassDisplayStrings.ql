/**
 * @name Display strings of Python classes
 * @description Shows all Python classes along with their names as display strings
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Retrieve all Python classes in the codebase
from Class classObj
// Output each class and its corresponding name as a display string
select classObj, classObj.getName()