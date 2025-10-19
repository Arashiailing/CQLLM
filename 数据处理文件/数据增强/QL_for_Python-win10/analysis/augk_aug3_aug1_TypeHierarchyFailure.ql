/**
 * @name Class inheritance hierarchy inference failure
 * @description Detects classes for which the inheritance hierarchy could not be resolved
 *              during the analysis process, which may impact the accuracy of analysis outcomes.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Find classes experiencing inheritance inference problems along with the reasons for failure
from Class problematicClass, string failureReason
where exists(ClassObject classObj | 
    classObj.getPyClass() = problematicClass and 
    classObj.failedInference(failureReason))
select problematicClass, "Failed to determine inheritance hierarchy for class '" + problematicClass.getName() + "': " + failureReason + "."