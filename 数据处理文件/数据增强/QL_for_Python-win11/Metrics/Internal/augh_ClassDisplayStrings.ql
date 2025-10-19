/**
 * @name Show class names as display strings
 * @kind display-string
 * @id py/lgtm/class-name-display
 * @metricType reftype
 */

import python

// Query to retrieve all classes in the codebase
from Class classObj
// Output each class along with its name as the display string
select classObj, classObj.getName()