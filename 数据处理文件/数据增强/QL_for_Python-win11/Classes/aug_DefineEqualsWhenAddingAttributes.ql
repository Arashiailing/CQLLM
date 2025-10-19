/**
 * @name `__eq__` not overridden when adding attributes
 * @description Classes that add new attributes to their instances should define equality (__eq__).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/missing-equals
 */

import python

// 检查类是否在自身属性存储中存储了某个属性
predicate classHasAttributeStorage(ClassValue targetClass, SelfAttributeStore attributeStore, string attributeName) {
  exists(FunctionValue method |
    method = targetClass.declaredAttribute(_) and 
    attributeStore.getScope() = method.getScope() and 
    attributeStore.getName() = attributeName
  ) and
  /* 排除用作元类的类 */
  not targetClass.getASuperType() = ClassValue::type()
}

// 判断类是否需要重写 __eq__ 方法
predicate requiresEqOverride(ClassValue targetClass, Value inheritedEqMethod) {
  not targetClass.declaresAttribute("__eq__") and
  exists(ClassValue superClass | 
    superClass = targetClass.getABaseType() and 
    superClass.declaredAttribute("__eq__") = inheritedEqMethod |
    // 检查继承的 __eq__ 方法是否是 object 的默认实现
    not inheritedEqMethod = ClassValue::object().declaredAttribute("__eq__")
  )
}

/**
 * 检查继承的 __eq__ 方法是否访问了属性，
 * 这意味着 __eq__ 方法不需要被重写。
 */
predicate parentEqMethodAccessesAttribute(ClassValue targetClass, FunctionValue inheritedEqMethod, string attributeName) {
  not targetClass.declaresAttribute("__eq__") and
  exists(ClassValue superClass | 
    superClass = targetClass.getABaseType() and 
    superClass.declaredAttribute("__eq__") = inheritedEqMethod |
    exists(SelfAttributeRead attributeAccess | 
      attributeAccess.getName() = attributeName and
      attributeAccess.getScope() = inheritedEqMethod.getScope()
    )
  )
}

from ClassValue targetClass, SelfAttributeStore attributeStore, Value inheritedEqMethod
where
  classHasAttributeStorage(targetClass, attributeStore, _) and // 检查类是否存储了属性
  requiresEqOverride(targetClass, inheritedEqMethod) and // 检查类是否需要重写 __eq__
  /* 不报告 unittest.TestCase 的子类，因为它们处理相等性的方式不同 */
  not targetClass.getASuperType().getName() = "TestCase" and
  not parentEqMethodAccessesAttribute(targetClass, inheritedEqMethod, attributeStore.getName()) // 检查父类的 __eq__ 是否期望该属性
select targetClass,
  "The class '" + targetClass.getName() + "' does not override $@, but adds the new attribute $@.", 
  inheritedEqMethod, "'__eq__'", attributeStore, attributeStore.getName()