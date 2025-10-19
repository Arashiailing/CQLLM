/**
 * @name Python Class Display Strings
 * @description Displays all Python classes with their corresponding names as display strings
 * @kind display-string
 * @id py/lgtm/class-display-strings
 * @metricType reftype
 */

import python

// Identify all Python classes defined in the codebase
from Class cls
// Output each class object along with its name as a display string
select cls, cls.getName()