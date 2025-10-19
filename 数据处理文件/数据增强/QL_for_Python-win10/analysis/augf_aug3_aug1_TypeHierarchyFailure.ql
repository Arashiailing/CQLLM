/**
 * @name Class inheritance hierarchy inference failure
 * @description Identifies classes where the inheritance hierarchy could not be determined
 *              during analysis, potentially reducing the precision of the analysis results.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Identify classes with inheritance inference issues and their corresponding failure causes
from Class targetClass, string cause
where exists(ClassObject classObj | 
    classObj.getPyClass() = targetClass and 
    classObj.failedInference(cause))
select targetClass, "Inference of class hierarchy failed for class '" + targetClass.getName() + "': " + cause + "."