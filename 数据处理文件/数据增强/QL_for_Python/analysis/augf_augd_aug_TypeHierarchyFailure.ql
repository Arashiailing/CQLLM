/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Detects classes where CodeQL was unable to resolve their inheritance structure.
 *              When inheritance inference fails, the analysis may produce incomplete results,
 *              since understanding class relationships is essential for accurate code analysis.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// This query identifies classes that experienced issues during inheritance analysis.
// It reports each affected class along with the specific cause of the inference failure.
from Class targetClass, string failureCause
where 
  // Check if any class instance of our target class has inheritance inference problems
  exists(ClassObject objectInstance | 
    // Associate the object instance with the class we're investigating
    objectInstance.getPyClass() = targetClass and 
    // Verify that inheritance inference failed for this instance
    objectInstance.failedInference(failureCause)
  )
select targetClass, 
       "Inference of class hierarchy failed for class '" + targetClass.getName() + 
       "': " + failureCause + "."