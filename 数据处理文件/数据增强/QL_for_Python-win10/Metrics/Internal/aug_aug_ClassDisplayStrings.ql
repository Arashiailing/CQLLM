/**
 * @name Display strings of classes
 * @description This query identifies all Python classes in the codebase and presents their names as display strings.
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Identify all Python classes in the codebase
from Class classObj

// Output each class object along with its name as a display string
select classObj, classObj.getName()