/**
 * @name Source Links for Python Classes
 * @description Identifies and locates all class definitions in Python code, providing complete path information to their source files
 * @kind source-link
 * @id py/class-source-links
 * @metricType reftype
 */

import python

// Define a variable to represent each Python class in the codebase
from Class pythonClass

// Extract the source file location for each identified class
// The location provides the file path where the class is defined
select pythonClass, pythonClass.getLocation().getFile()