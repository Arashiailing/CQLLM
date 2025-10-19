/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Identifies classes where the analysis engine was unable to determine their inheritance relationships,
 *              potentially leading to incomplete or inaccurate analysis results.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Identify classes where the inheritance hierarchy inference process encountered errors
// and retrieve the corresponding error message explaining the failure
from Class classWithFailedInference, string failureMessage
where 
  // Verify that there exists a class instance (ClassObject) associated with our target class
  // which has experienced a failure during inheritance inference analysis
  exists(ClassObject classInstance | 
    classInstance.getPyClass() = classWithFailedInference and 
    classInstance.failedInference(failureMessage)
  )
select classWithFailedInference, "Inference of class hierarchy failed for class '" + classWithFailedInference.getName() + "': " + failureMessage + "."