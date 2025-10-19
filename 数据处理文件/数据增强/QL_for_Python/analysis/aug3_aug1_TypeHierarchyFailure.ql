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
from Class affectedClass, string inferenceFailureCause
where exists(ClassObject classRepresentation | 
    classRepresentation.getPyClass() = affectedClass and 
    classRepresentation.failedInference(inferenceFailureCause))
select affectedClass, "Inference of class hierarchy failed for class '" + affectedClass.getName() + "': " + inferenceFailureCause + "."