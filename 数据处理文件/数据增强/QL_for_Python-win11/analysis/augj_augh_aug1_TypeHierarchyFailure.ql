/**
 * @name Class inheritance hierarchy inference failure
 * @description Detects classes where inheritance hierarchy analysis fails,
 *              which may impact the precision of static analysis results.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Identify classes experiencing inheritance inference failures and their specific causes
from Class targetClass, string failureReason
where 
  exists(ClassObject classObj | 
    classObj.getPyClass() = targetClass and 
    classObj.failedInference(failureReason))
select targetClass, "Inference of class hierarchy failed for class '" + targetClass.getName() + "': " + failureReason + "."