/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Descriptor objects can be shared across many instances. Mutating them can cause strange side effects or race conditions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/mutable-descriptor
 */

import python

// 检测描述符类中是否存在变异操作
predicate has_descriptor_mutation(ClassObject descClass, SelfAttributeStore mutation) {
  // 确保目标类实现了描述符协议
  descClass.isDescriptorType() and
  // 查找描述符协议方法 (__get__/__set__/__delete__)
  exists(PyFunctionObject descMethod, string protocolMethod |
    descClass.lookupAttribute(protocolMethod) = descMethod and
    (protocolMethod = "__get__" or protocolMethod = "__set__" or protocolMethod = "__delete__") and
    // 查找被描述符方法调用的类方法
    exists(PyFunctionObject invokedMethod |
      // 被调用方法属于描述符类
      descClass.lookupAttribute(_) = invokedMethod and
      // 描述符方法直接或间接调用该方法
      descMethod.getACallee*() = invokedMethod and
      // 排除初始化方法
      not invokedMethod.getName() = "__init__" and
      // 变异操作发生在被调用方法的作用域内
      mutation.getScope() = invokedMethod.getFunction()
    )
  )
}

// 定位存在描述符变异的类和操作
from ClassObject descClass, SelfAttributeStore mutation
where has_descriptor_mutation(descClass, mutation)
// 输出变异操作位置、警告信息、相关类及其名称
select mutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()