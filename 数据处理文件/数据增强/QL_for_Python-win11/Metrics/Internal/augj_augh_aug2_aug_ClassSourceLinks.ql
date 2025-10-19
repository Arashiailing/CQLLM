/**
 * @name Source Links for Python Classes
 * @description Locates all Python class definitions and provides their source file paths
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// For each Python class in the codebase
from Class cls

// Extract the source file location
select cls, cls.getLocation().getFile()