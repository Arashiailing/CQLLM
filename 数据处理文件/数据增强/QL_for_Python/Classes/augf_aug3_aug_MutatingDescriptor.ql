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

// 识别描述符类中的状态变更操作
predicate contains_descriptor_state_change(ClassObject descriptorCls, SelfAttributeStore stateChange) {
  // 确认类遵循描述符接口规范
  descriptorCls.isDescriptorType() and
  // 定位描述符方法及其关联的函数调用链
  exists(PyFunctionObject descriptorMethod, string protocolMethodName, PyFunctionObject invokedFunction |
    // 识别符合描述符协议的方法
    descriptorCls.lookupAttribute(protocolMethodName) = descriptorMethod and
    protocolMethodName in ["__get__", "__set__", "__delete__"] and
    // 追踪描述符方法内部调用的类成员函数
    descriptorCls.lookupAttribute(_) = invokedFunction and
    // 过滤构造方法并确认函数调用关系
    not invokedFunction.getName() = "__init__" and
    descriptorMethod.getACallee*() = invokedFunction and
    // 确保状态变更操作位于被调用函数的作用域中
    stateChange.getScope() = invokedFunction.getFunction()
  )
}

// 查找包含描述符状态变更的类及其相关操作
from ClassObject descriptorCls, SelfAttributeStore stateChange
where contains_descriptor_state_change(descriptorCls, stateChange)
// 展示状态变更位置、警告提示、关联类及其标识符
select stateChange,
  "Mutation of descriptor $@ object may lead to action-at-a-distance effects or race conditions for properties.",
  descriptorCls, descriptorCls.getName()