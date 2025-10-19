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
predicate has_descriptor_mutation(ClassObject descClass, SelfAttributeStore mutation) {
  // 验证目标类实现了描述符协议
  descClass.isDescriptorType() and
  // 查找描述符协议方法 (__get__/__set__/__delete__)
  exists(PyFunctionObject descMethod, string protocolMethod |
    // 获取描述符协议方法实现
    descClass.lookupAttribute(protocolMethod) = descMethod and
    // 匹配描述符协议方法名称
    (protocolMethod = "__get__" or protocolMethod = "__set__" or protocolMethod = "__delete__") and
    // 查找被描述符方法调用的类成员函数
    exists(PyFunctionObject memberFunc |
      // 被调用函数是目标类的成员方法
      descClass.lookupAttribute(_) = memberFunc and
      // 描述符方法直接或间接调用了该成员函数
      descMethod.getACallee*() = memberFunc and
      // 排除初始化方法(__init__)
      not memberFunc.getName() = "__init__" and
      // 变异操作发生在成员函数作用域内
      mutation.getScope() = memberFunc.getFunction()
    )
  )
}

// 查找存在描述符变异的类和操作
from ClassObject descClass, SelfAttributeStore mutation
where has_descriptor_mutation(descClass, mutation)
// 输出变异操作位置、警告信息、相关类及其名称
select mutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descClass, descClass.getName()