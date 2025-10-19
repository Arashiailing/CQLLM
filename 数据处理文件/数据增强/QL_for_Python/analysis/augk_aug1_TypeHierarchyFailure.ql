/**
 * @name Class inheritance hierarchy inference failure
 * @description Identifies classes where the inheritance hierarchy inference process failed,
 *              potentially reducing analysis precision and completeness.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Define variables to capture classes with inheritance inference issues
from Class problematicClass, string hierarchyFailureReason

// Check if there exists a class object representing our target class
// that has experienced inference failures
where exists(ClassObject classObj | 
    classObj.getPyClass() = problematicClass and 
    classObj.failedInference(hierarchyFailureReason))

// Output the problematic class along with detailed failure information
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + hierarchyFailureReason + "."