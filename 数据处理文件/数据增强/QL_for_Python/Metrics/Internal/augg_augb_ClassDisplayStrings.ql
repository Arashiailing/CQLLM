/**
 * @name Display strings of Python classes
 * @description Shows all Python classes along with their names as display strings
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Identify all Python classes in the codebase and extract their names
from Class cls
select cls, cls.getName()