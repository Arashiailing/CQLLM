/**
 * @name Class inheritance hierarchy inference failure
 * @description Detects classes for which the inheritance hierarchy could not be resolved
 *              during static analysis, which may lead to reduced precision in analysis outcomes.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Identify classes experiencing inheritance inference issues and their specific failure reasons
from Class problematicClass, string failureReason
where 
    // Check if there's a class model representation that failed to infer inheritance
    exists(ClassObject classModel | 
        classModel.getPyClass() = problematicClass and 
        classModel.failedInference(failureReason))
select 
    problematicClass, 
    "Inference of class hierarchy failed for class '" + 
    problematicClass.getName() + 
    "': " + 
    failureReason + 
    "."