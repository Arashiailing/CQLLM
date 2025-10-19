/**
 * @name Inheritance hierarchy cannot be inferred for class
 * @description Inability to infer the inheritance hierarchy for a class will impair analysis.
 * @id py/failed-inheritance-inference
 * @kind problem
 * @problem.severity info
 * @tags debug
 */

import python

// 从类和字符串原因中选择，其中存在一个类对象c，使得c的Python类等于cls，并且c的推理失败原因是reason
from Class cls, string reason
where exists(ClassObject c | c.getPyClass() = cls | c.failedInference(reason))
select cls, "Inference of class hierarchy failed for class '" + cls.getName() + "': " + reason + "."
