/**
 * @name Class inheritance hierarchy inference failure
 * @description Identifies classes where the inheritance hierarchy could not be determined
 *              during analysis, potentially reducing the precision of the results.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Identify classes with inheritance hierarchy inference failures and their associated reasons
from Class problematicClass, string inferenceFailureCause
where exists(ClassObject classInstance | 
    classInstance.getPyClass() = problematicClass and 
    classInstance.failedInference(inferenceFailureCause))
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + inferenceFailureCause + "."