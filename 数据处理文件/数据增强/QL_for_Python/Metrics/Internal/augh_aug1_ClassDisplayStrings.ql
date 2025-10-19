/**
 * @name Display string representations for Python classes
 * @description Identifies all Python classes within the codebase
 *              and presents them along with their names as display strings.
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Retrieve every Python class definition found in the codebase
from Class pyCls
// Output the class entity and its name as the display string representation
select pyCls, pyCls.getName()