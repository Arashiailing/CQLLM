/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description This query identifies Python classes for which the analysis engine was unable to infer the inheritance hierarchy.
 *              When inheritance inference fails, it can lead to incomplete or inaccurate analysis results, potentially
 *              missing important security vulnerabilities or code quality issues.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// 查找所有目标类和对应的失败原因，其中存在至少一个类实例，
// 该实例的Python类是目标类，并且该实例的继承推断失败
from Class problematicClass, string failureReason
where exists(ClassObject classInstance | 
    classInstance.getPyClass() = problematicClass | 
    classInstance.failedInference(failureReason)
)
select problematicClass, "Inference of class hierarchy failed for class '" + problematicClass.getName() + "': " + failureReason + "."