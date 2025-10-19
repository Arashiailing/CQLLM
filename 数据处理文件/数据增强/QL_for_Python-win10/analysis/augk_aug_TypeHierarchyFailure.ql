/**
 * @name Class inheritance inference failure
 * @description Detects classes for which the analysis engine was unable to resolve inheritance relationships,
 *              potentially leading to incomplete or imprecise analysis outcomes.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Identify classes where inheritance hierarchy inference failed and capture the associated error messages
from Class problematicClass, string errorReason
where 
  // Check for existence of class instances that reference our target problematic class
  exists(ClassObject instanceObj | 
    // Ensure the instance's Python class matches our problematic class
    instanceObj.getPyClass() = problematicClass and 
    // Verify that inheritance inference failed for this instance with a specific error
    instanceObj.failedInference(errorReason)
  )
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + errorReason + "."