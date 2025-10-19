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
 * 检测描述符类对象在其__get__/__set__/__delete__方法中发生变异的情况
 * 参数说明：
 *   descriptorClass - 被检查的描述符类对象
 *   attributeStore  - 发生变异的属性存储操作
 */
predicate mutates_descriptor(ClassObject descriptorClass, SelfAttributeStore attributeStore) {
  // 基础条件：必须是描述符类型
  descriptorClass.isDescriptorType() and
  
  // 存在变异函数和描述符方法
  exists(PyFunctionObject mutatedFunction, PyFunctionObject descriptorMethod |
    // 条件1：类中存在描述符方法(__get__/__set__/__delete__)
    exists(string methodName |
      descriptorClass.lookupAttribute(methodName) = descriptorMethod and
      (methodName = "__get__" or methodName = "__set__" or methodName = "__delete__")
    ) and
    
    // 条件2：类中包含变异函数
    descriptorClass.lookupAttribute(_) = mutatedFunction and
    
    // 条件3：描述符方法通过调用链触发了变异函数
    descriptorMethod.getACallee*() = mutatedFunction and
    
    // 条件4：变异函数不是初始化方法
    not mutatedFunction.getName() = "__init__" and
    
    // 条件5：属性变异发生在变异函数的作用域内
    attributeStore.getScope() = mutatedFunction.getFunction()
  )
}

// 主查询：检测所有描述符变异行为
from ClassObject descriptorClass, SelfAttributeStore attributeStore
where mutates_descriptor(descriptorClass, attributeStore)
select attributeStore,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorClass, descriptorClass.getName()