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

/**
 * 检测描述符类在其方法中发生的变异操作
 * @param descriptorClass - 被检查的描述符类对象
 * @param selfMutation - 对self属性的变异操作
 */
predicate mutates_descriptor(ClassObject descriptorClass, SelfAttributeStore selfMutation) {
  // 确保目标类是描述符类型
  descriptorClass.isDescriptorType() and
  
  // 检查描述符方法中是否存在变异操作
  exists(PyFunctionObject calledFunction, PyFunctionObject descriptorMethod |
    // 验证类中存在描述符协议方法
    exists(string methodName | 
      descriptorClass.lookupAttribute(methodName) = descriptorMethod and
      (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__")
    ) and
    
    // 确保变异操作发生在描述符方法调用的函数中
    descriptorClass.lookupAttribute(_) = calledFunction and
    descriptorMethod.getACallee*() = calledFunction and
    
    // 排除初始化方法，因为初始化时的变异是预期的
    not calledFunction.getName() = "__init__" and
    
    // 确认变异操作的作用域是当前函数
    selfMutation.getScope() = calledFunction.getFunction()
  )
}

// 查询所有在描述符方法中发生变异的类和操作
from ClassObject descriptorClass, SelfAttributeStore selfMutation
where mutates_descriptor(descriptorClass, selfMutation)
select selfMutation,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()