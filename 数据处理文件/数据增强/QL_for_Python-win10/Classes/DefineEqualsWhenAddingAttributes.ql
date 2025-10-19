/**
 * @name `__eq__` not overridden when adding attributes
 * @description 当向类的实例添加新属性时，需要为该类定义相等性（equality）。
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/missing-equals
 */

import python
import Equality

// 检查类是否将某个属性存储在自身属性存储中
predicate class_stores_to_attribute(ClassValue cls, SelfAttributeStore store, string name) {
  exists(FunctionValue f |
    f = cls.declaredAttribute(_) and store.getScope() = f.getScope() and store.getName() = name
  ) and
  /* 排除用作元类的类 */
  not cls.getASuperType() = ClassValue::type()
}

// 判断类是否需要重写 __eq__ 方法
predicate should_override_eq(ClassValue cls, Value base_eq) {
  not cls.declaresAttribute("__eq__") and
  exists(ClassValue sup | sup = cls.getABaseType() and sup.declaredAttribute("__eq__") = base_eq |
    not exists(GenericEqMethod eq | eq.getScope() = sup.getScope()) and
    not exists(IdentityEqMethod eq | eq.getScope() = sup.getScope()) and
    not base_eq.(FunctionValue).getScope() instanceof IdentityEqMethod and
    not base_eq = ClassValue::object().declaredAttribute("__eq__")
  )
}

/**
 * 未重写的 __eq__ 方法是否访问了属性，这意味着 __eq__ 方法不需要被重写。
 */
predicate superclassEqExpectsAttribute(ClassValue cls, FunctionValue base_eq, string attrname) {
  not cls.declaresAttribute("__eq__") and
  exists(ClassValue sup | sup = cls.getABaseType() and sup.declaredAttribute("__eq__") = base_eq |
    exists(SelfAttributeRead store | store.getName() = attrname |
      store.getScope() = base_eq.getScope()
    )
  )
}

from ClassValue cls, SelfAttributeStore store, Value base_eq
where
  class_stores_to_attribute(cls, store, _) and // 检查类是否将某个属性存储在自身属性存储中
  should_override_eq(cls, base_eq) and // 判断类是否需要重写 __eq__ 方法
  /* 不要报告覆盖的 unittest.TestCase。 -- TestCase 重写了 __eq__，但子类不需要真正重写。 */
  not cls.getASuperType().getName() = "TestCase" and
  not superclassEqExpectsAttribute(cls, base_eq, store.getName()) // 检查超类的 __eq__ 方法是否期望该属性
select cls,
  "The class '" + cls.getName() + "' does not override $@, but adds the new attribute $@.", base_eq,
  "'__eq__'", store, store.getName() // 选择类和相关信息进行报告
