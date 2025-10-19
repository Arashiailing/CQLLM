/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description This query identifies classes where the analysis engine failed to determine their inheritance relationships,
 *              which may result in incomplete or inaccurate analysis results.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Select classes and their corresponding failure messages when inheritance inference fails
from Class targetClass, string failureCause
where 
  // There exists at least one class instance whose Python class is our target class
  exists(ClassObject classInstance | 
    classInstance.getPyClass() = targetClass and 
    // And for which the inheritance inference process failed with a specific reason
    classInstance.failedInference(failureCause)
  )
select targetClass, "Inference of class hierarchy failed for class '" + targetClass.getName() + "': " + failureCause + "."