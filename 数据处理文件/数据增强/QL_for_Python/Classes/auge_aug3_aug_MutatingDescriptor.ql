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
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore attributeMutation) {
  // 验证目标类实现了描述符协议
  descriptorClass.isDescriptorType() and
  // 定位描述符协议方法及其调用链
  exists(
    PyFunctionObject descriptorMethod, string descriptorMethodName, 
    PyFunctionObject invokedMemberFunction
  |
    // 识别描述符协议方法 (__get__/__set__/__delete__)
    descriptorClass.lookupAttribute(descriptorMethodName) = descriptorMethod and
    (
      descriptorMethodName = "__get__" or 
      descriptorMethodName = "__set__" or 
      descriptorMethodName = "__delete__"
    ) and
    // 查找被描述符方法调用的类成员函数
    descriptorClass.lookupAttribute(_) = invokedMemberFunction and
    // 排除初始化方法并验证调用关系
    not invokedMemberFunction.getName() = "__init__" and
    descriptorMethod.getACallee*() = invokedMemberFunction and
    // 确认变异操作发生在被调用函数的作用域内
    attributeMutation.getScope() = invokedMemberFunction.getFunction()
  )
}

// 定位存在描述符变异的类及其操作
from ClassObject descriptorClass, SelfAttributeStore attributeMutation
where has_descriptor_mutation(descriptorClass, attributeMutation)
// 输出变异操作位置、警告信息、相关类及其名称
select attributeMutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()