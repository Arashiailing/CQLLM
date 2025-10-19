/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Inability to infer the inheritance hierarchy for a class will impair analysis.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// 查找所有继承层次结构推断失败的类及其失败原因
// 当存在类实例对象，其对应的类定义无法正确推断继承关系时，将被捕获
from Class targetClass, string failureReason
where exists(ClassObject classInstance |
    classInstance.getPyClass() = targetClass and
    classInstance.failedInference(failureReason)
)
select targetClass, "Inference of class hierarchy failed for class '" + targetClass.getName() + "': " + failureReason + "."