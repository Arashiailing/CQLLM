/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Identifies classes where the CodeQL analysis engine failed to determine their inheritance relationships.
 *              Such failures may lead to incomplete or inaccurate analysis results, as the class hierarchy
 *              information is crucial for understanding the code structure and behavior.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// This query detects classes for which the inheritance inference process was unsuccessful.
// We select the problematic class along with the specific reason why the inference failed.
from Class problematicClass, string inferenceFailureReason
where 
  // Verify that at least one class object instance of our target class
  // encountered a failure during the inheritance inference process.
  exists(ClassObject classObjectInstance | 
    // Ensure the class object instance belongs to our problematic class
    classObjectInstance.getPyClass() = problematicClass and 
    // Confirm that the inheritance inference failed for this instance
    classObjectInstance.failedInference(inferenceFailureReason)
  )
select problematicClass, 
       "Inference of class hierarchy failed for class '" + problematicClass.getName() + 
       "': " + inferenceFailureReason + "."