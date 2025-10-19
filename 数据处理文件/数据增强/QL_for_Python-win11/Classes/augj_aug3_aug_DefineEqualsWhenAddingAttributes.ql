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
predicate storesInstanceAttribute(ClassValue targetClass, SelfAttributeStore attributeStorage, string attributeName) {
  exists(FunctionValue method |
    method = targetClass.declaredAttribute(_) and 
    attributeStorage.getScope() = method.getScope() and 
    attributeStorage.getName() = attributeName
  ) and
  /* Exclude metaclass candidates */
  not targetClass.getASuperType() = ClassValue::type()
}

// Determines if class requires custom __eq__ implementation
predicate needsCustomEquality(ClassValue targetClass, Value inheritedEqualityMethod) {
  not targetClass.declaresAttribute("__eq__") and
  exists(ClassValue parentClass | 
    parentClass = targetClass.getABaseType() and 
    parentClass.declaredAttribute("__eq__") = inheritedEqualityMethod |
    // Verify inherited __eq__ isn't from object base class
    not inheritedEqualityMethod = ClassValue::object().declaredAttribute("__eq__")
  )
}

/**
 * Checks if parent class's __eq__ method references attributes,
 * indicating no override is needed.
 */
predicate parentEqReferencesAttribute(ClassValue targetClass, FunctionValue inheritedEqualityMethod, string attributeName) {
  not targetClass.declaresAttribute("__eq__") and
  exists(ClassValue parentClass | 
    parentClass = targetClass.getABaseType() and 
    parentClass.declaredAttribute("__eq__") = inheritedEqualityMethod |
    exists(SelfAttributeRead attributeRead | 
      attributeRead.getName() = attributeName and
      attributeRead.getScope() = inheritedEqualityMethod.getScope()
    )
  )
}

from ClassValue targetClass, SelfAttributeStore attributeStorage, Value inheritedEqualityMethod
where
  // Verify attribute storage exists in class
  storesInstanceAttribute(targetClass, attributeStorage, _) and
  // Check if __eq__ override is required
  needsCustomEquality(targetClass, inheritedEqualityMethod) and
  // Exclude unittest.TestCase subclasses with special equality handling
  not targetClass.getASuperType().getName() = "TestCase" and
  // Ensure parent __eq__ doesn't expect the new attribute
  not parentEqReferencesAttribute(targetClass, inheritedEqualityMethod, attributeStorage.getName())
select targetClass,
  "Class '" + targetClass.getName() + "' doesn't override $@ but introduces new attribute $@.", 
  inheritedEqualityMethod, "'__eq__'", attributeStorage, attributeStorage.getName()