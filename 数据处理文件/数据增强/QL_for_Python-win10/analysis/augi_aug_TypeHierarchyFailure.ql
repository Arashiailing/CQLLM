/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Identifies classes where the analysis engine was unable to determine their inheritance relationships,
 *              potentially leading to incomplete or inaccurate analysis outcomes.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Find classes and their associated failure messages when inheritance inference encounters issues
from Class problematicClass, string inferenceFailureReason
where 
  // There is at least one class instance that belongs to our problematic class
  exists(ClassObject instanceOfClass | 
    instanceOfClass.getPyClass() = problematicClass and 
    // And the inheritance inference process for this instance failed with a specific cause
    instanceOfClass.failedInference(inferenceFailureReason)
  )
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + inferenceFailureReason + "."