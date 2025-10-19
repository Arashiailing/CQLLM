/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects are shared across instances. Mutating them may cause unexpected side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// 检测描述符类中的变异操作
predicate has_descriptor_mutation(ClassObject descClass, SelfAttributeStore mutation) {
  // 验证类实现描述符协议
  descClass.isDescriptorType() and
  // 查找描述符方法 (__get__/__set__/__delete__) 及其调用链
  exists(PyFunctionObject descMethod, string methodName, PyFunctionObject calledFunc |
    // 确定描述符协议方法
    descClass.lookupAttribute(methodName) = descMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // 查找被描述符方法调用的类成员函数
    descClass.lookupAttribute(_) = calledFunc and
    // 排除初始化方法并验证调用关系
    not calledFunc.getName() = "__init__" and
    descMethod.getACallee*() = calledFunc and
    // 确认变异操作发生在被调用函数作用域内
    mutation.getScope() = calledFunc.getFunction()
  )
}

// 定位存在描述符变异的类及其操作
from ClassObject descClass, SelfAttributeStore mutation
where has_descriptor_mutation(descClass, mutation)
// 输出变异操作位置、警告信息、相关类及其名称
select mutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()