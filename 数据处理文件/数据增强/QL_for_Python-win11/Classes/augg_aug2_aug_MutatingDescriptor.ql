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

// 检测描述符类中可能存在的变异操作
// 这些变异操作必须发生在描述符协议方法调用的非初始化函数中
predicate has_descriptor_mutation(ClassObject descriptorCls, SelfAttributeStore mutationOperation) {
  // 验证目标类实现了描述符协议
  descriptorCls.isDescriptorType() and
  // 查找类中实现的描述符协议方法 (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string protocolMethodName |
    // 确保是描述符协议方法之一
    descriptorCls.lookupAttribute(protocolMethodName) = descriptorMethod and
    (protocolMethodName = "__get__" or protocolMethodName = "__set__" or protocolMethodName = "__delete__") and
    // 检查描述符方法调用的函数中是否存在变异操作
    exists(PyFunctionObject calledFunction |
      // 被调用函数必须是描述符类的成员方法
      descriptorCls.lookupAttribute(_) = calledFunction and
      // 描述符方法直接或间接调用了该函数
      descriptorMethod.getACallee*() = calledFunction and
      // 排除初始化方法，因为初始化过程中的变异通常是预期的
      not calledFunction.getName() = "__init__" and
      // 确保变异操作发生在被调用函数的作用域内
      mutationOperation.getScope() = calledFunction.getFunction()
    )
  )
}

// 查找所有存在描述符变异的类和相关操作
from ClassObject descriptorCls, SelfAttributeStore mutationOperation
where has_descriptor_mutation(descriptorCls, mutationOperation)
// 输出变异操作位置、警告信息、相关类及其名称
select mutationOperation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()