/**
 * @name Python Class Display Strings
 * @description Identifies and enumerates all Python classes in the codebase, 
 *              presenting their names as formatted strings for convenient reference.
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Obtain all Python class definitions found in the analyzed codebase
from Class cls

// Output each class entity paired with its corresponding name as a display string
select cls, cls.getName()