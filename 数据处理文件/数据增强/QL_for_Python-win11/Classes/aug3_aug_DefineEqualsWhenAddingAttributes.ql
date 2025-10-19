/**
 * @name Missing `__eq__` override when adding instance attributes
 * @description Classes that introduce new instance attributes should override equality (__eq__) method.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/missing-equals
 */

import python

// Identifies classes storing attributes in their instance storage
predicate storesInstanceAttribute(ClassValue cls, SelfAttributeStore attrStore, string attrName) {
  exists(FunctionValue func |
    func = cls.declaredAttribute(_) and 
    attrStore.getScope() = func.getScope() and 
    attrStore.getName() = attrName
  ) and
  /* Exclude metaclass candidates */
  not cls.getASuperType() = ClassValue::type()
}

// Determines if class requires custom __eq__ implementation
predicate needsCustomEquality(ClassValue cls, Value inheritedEq) {
  not cls.declaresAttribute("__eq__") and
  exists(ClassValue parentCls | 
    parentCls = cls.getABaseType() and 
    parentCls.declaredAttribute("__eq__") = inheritedEq |
    // Verify inherited __eq__ isn't from object base class
    not inheritedEq = ClassValue::object().declaredAttribute("__eq__")
  )
}

/**
 * Checks if parent class's __eq__ method references attributes,
 * indicating no override is needed.
 */
predicate parentEqReferencesAttribute(ClassValue cls, FunctionValue inheritedEq, string attrName) {
  not cls.declaresAttribute("__eq__") and
  exists(ClassValue parentCls | 
    parentCls = cls.getABaseType() and 
    parentCls.declaredAttribute("__eq__") = inheritedEq |
    exists(SelfAttributeRead attrRead | 
      attrRead.getName() = attrName and
      attrRead.getScope() = inheritedEq.getScope()
    )
  )
}

from ClassValue cls, SelfAttributeStore attrStore, Value inheritedEq
where
  storesInstanceAttribute(cls, attrStore, _) and // Verify attribute storage
  needsCustomEquality(cls, inheritedEq) and // Check if __eq__ override is required
  /* Exclude unittest.TestCase subclasses with special equality handling */
  not cls.getASuperType().getName() = "TestCase" and
  not parentEqReferencesAttribute(cls, inheritedEq, attrStore.getName()) // Ensure parent __eq__ doesn't expect attribute
select cls,
  "Class '" + cls.getName() + "' doesn't override $@ but introduces new attribute $@.", 
  inheritedEq, "'__eq__'", attrStore, attrStore.getName()