/**
 * @name Class inheritance hierarchy inference failure
 * @description Detects classes for which the inheritance hierarchy could not be resolved
 *              during the analysis process, which may lead to decreased precision in analysis results.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Find classes that have inheritance inference failures and the corresponding failure reasons
from Class classWithFailedInference, string failureReason
where 
    exists(ClassObject classObj | 
        classObj.getPyClass() = classWithFailedInference and 
        classObj.failedInference(failureReason))
select classWithFailedInference, 
    "Inference of class hierarchy failed for class '" + 
    classWithFailedInference.getName() + 
    "': " + 
    failureReason + 
    "."