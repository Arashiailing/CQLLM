/**
 * @name Class inheritance hierarchy inference failure
 * @description Identifies classes where the static analysis engine was unable to resolve 
 *              their inheritance hierarchy, potentially reducing analysis precision.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Find classes with inheritance inference problems and corresponding error details
from Class targetClass, string inferenceError
where 
    // Verify existence of a class model representation with inference failure
    exists(ClassObject classRepresentation | 
        classRepresentation.getPyClass() = targetClass and 
        classRepresentation.failedInference(inferenceError))
select 
    targetClass, 
    "Inference of class hierarchy failed for class '" + 
    targetClass.getName() + 
    "': " + 
    inferenceError + 
    "."