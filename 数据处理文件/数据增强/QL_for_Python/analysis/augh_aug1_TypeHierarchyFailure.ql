/**
 * @name Class inheritance hierarchy inference failure
 * @description Identifies classes where the inheritance hierarchy cannot be determined,
 *              potentially reducing analysis precision and accuracy.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Detect classes with inheritance inference failures and their root causes
from Class problematicClass, string inferenceFailureCause
where 
  exists(ClassObject classInstance | 
    classInstance.getPyClass() = problematicClass and 
    classInstance.failedInference(inferenceFailureCause))
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + inferenceFailureCause + "."