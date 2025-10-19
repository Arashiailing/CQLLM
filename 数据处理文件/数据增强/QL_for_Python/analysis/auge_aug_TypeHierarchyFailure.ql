/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Identifies classes where the analysis engine was unable to determine their inheritance relationships,
 *              potentially leading to incomplete or inaccurate analysis results.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// Find classes where inheritance inference failed and capture the error message
from Class problematicClass, string inferenceError
where 
  // Check for existence of a class object that belongs to our problematic class
  // and has experienced inheritance inference failure
  exists(ClassObject classObj | 
    classObj.getPyClass() = problematicClass and 
    classObj.failedInference(inferenceError)
  )
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + inferenceError + "."