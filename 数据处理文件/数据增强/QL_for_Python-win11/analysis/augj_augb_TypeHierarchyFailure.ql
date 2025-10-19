/**
 * @name Class inheritance hierarchy inference failure
 * @description Analysis effectiveness is reduced when the inheritance hierarchy of a class cannot be determined.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Identify classes where the inheritance hierarchy inference has failed, along with the reason for failure
// This query captures cases where class instances exist but their corresponding class definitions 
// have problematic inheritance relationships that cannot be properly resolved

from Class problematicClass, string errorDetail
where exists(ClassObject classInstance |
    classInstance.getPyClass() = problematicClass and
    classInstance.failedInference(errorDetail)
)
select problematicClass, "Class hierarchy inference failed for '" + problematicClass.getName() + "': " + errorDetail + "."