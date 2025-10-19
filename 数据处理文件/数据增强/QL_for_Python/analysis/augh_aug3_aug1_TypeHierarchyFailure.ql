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

// Find classes that have associated ClassObject representations
// where inheritance inference has failed, capturing the failure reason
from Class problematicClass, string inferenceError
where exists(ClassObject classObj | 
    classObj.getPyClass() = problematicClass and 
    classObj.failedInference(inferenceError))
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + inferenceError + "."