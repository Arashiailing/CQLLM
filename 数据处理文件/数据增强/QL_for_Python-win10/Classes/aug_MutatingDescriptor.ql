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

// 检查描述符类中是否存在变异操作
predicate has_descriptor_mutation(ClassObject descriptorClass, SelfAttributeStore mutationOp) {
  // 确保类是描述符类型
  descriptorClass.isDescriptorType() and
  // 查找描述符协议方法 (__get__/__set__/__delete__)
  exists(PyFunctionObject descriptorMethod, string methodName |
    descriptorClass.lookupAttribute(methodName) = descriptorMethod and
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // 查找被描述符方法调用的函数
    exists(PyFunctionObject calledFunction |
      // 被调用函数是类的方法
      descriptorClass.lookupAttribute(_) = calledFunction and
      // 描述符方法直接或间接调用了该函数
      descriptorMethod.getACallee*() = calledFunction and
      // 排除初始化方法
      not calledFunction.getName() = "__init__" and
      // 变异操作发生在被调用函数的作用域内
      mutationOp.getScope() = calledFunction.getFunction()
    )
  )
}

// 查找存在描述符变异的类和操作
from ClassObject descriptorClass, SelfAttributeStore mutationOp
where has_descriptor_mutation(descriptorClass, mutationOp)
// 输出变异操作位置、警告信息、相关类及其名称
select mutationOp,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()