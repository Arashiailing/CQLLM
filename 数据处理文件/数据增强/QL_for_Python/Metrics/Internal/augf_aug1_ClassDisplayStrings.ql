/**
 * @name Display string representations of Python classes
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Identify all Python classes in the codebase
from Class cls
// Output the class object and its name as display string
select cls, cls.getName()