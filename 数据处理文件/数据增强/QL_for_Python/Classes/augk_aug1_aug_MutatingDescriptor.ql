/**
 * @name Mutation of descriptor in `__get__` or `__set__` method.
 * @description Detects mutations to descriptor objects in descriptor protocol methods.
 *              Descriptor objects are often shared across instances, and mutating them
 *              can lead to unexpected side effects or race conditions.
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
predicate has_descriptor_mutation(ClassObject descriptorCls, SelfAttributeStore mutationOp) {
  // 验证目标类实现了描述符协议
  descriptorCls.isDescriptorType() and
  // 查找描述符协议方法 (__get__/__set__/__delete__)
  exists(PyFunctionObject protocolMethod, string methodName |
    // 获取描述符协议方法实现
    descriptorCls.lookupAttribute(methodName) = protocolMethod and
    // 匹配描述符协议方法名称
    (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__") and
    // 查找被描述符方法调用的类成员函数
    exists(PyFunctionObject memberMethod |
      // 被调用函数是目标类的成员方法
      descriptorCls.lookupAttribute(_) = memberMethod and
      // 描述符方法直接或间接调用了该成员函数
      protocolMethod.getACallee*() = memberMethod and
      // 排除初始化方法(__init__)
      not memberMethod.getName() = "__init__" and
      // 变异操作发生在成员函数作用域内
      mutationOp.getScope() = memberMethod.getFunction()
    )
  )
}

// 查找存在描述符变异的类和操作
from ClassObject descriptorCls, SelfAttributeStore mutationOp
where has_descriptor_mutation(descriptorCls, mutationOp)
// 输出变异操作位置、警告信息、相关类及其名称
select mutationOp,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()