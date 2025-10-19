/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Identifies classes for which CodeQL could not determine their inheritance relationships.
 *              Failure to infer class hierarchies may lead to incomplete analysis results,
 *              as class relationships are fundamental for comprehensive code understanding.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// This query pinpoints classes that encountered difficulties during inheritance analysis.
// It outputs each problematic class alongside the specific reason for the inference failure.
from Class problematicClass, string inferenceError
where 
  // Check if there's any class instance with inheritance inference problems
  exists(ClassObject classInstance | 
    // Ensure the instance belongs to our target class
    classInstance.getPyClass() = problematicClass and 
    // Confirm that inheritance inference failed for this instance
    classInstance.failedInference(inferenceError)
  )
select problematicClass, 
       "Inference of class hierarchy failed for class '" + problematicClass.getName() + 
       "': " + inferenceError + "."