/**
 * @name Class inheritance hierarchy inference failure
 * @description Detects classes for which the inheritance hierarchy cannot be inferred,
 *              which may negatively impact the analysis accuracy.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// 查找所有继承层次结构推断失败的类及其失败原因
from Class targetClass, string failureReason
where exists(ClassObject classObj | 
    classObj.getPyClass() = targetClass and 
    classObj.failedInference(failureReason))
select targetClass, "Inference of class hierarchy failed for class '" + targetClass.getName() + "': " + failureReason + "."