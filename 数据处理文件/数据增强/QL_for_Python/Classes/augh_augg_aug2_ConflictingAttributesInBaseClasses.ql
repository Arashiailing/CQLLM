/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute, which may lead to unexpected behavior due to attribute overriding.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       modularity
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/conflicting-attributes
 */

import python

/**
 * Checks if a function is effectively empty, containing only pass statements and docstrings.
 */
predicate is_trivial_function(PyFunctionObject function) {
  not exists(Stmt statement | statement.getScope() = function.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

/**
 * Determines if a function explicitly calls parent class methods using super().
 */
predicate uses_super_call(FunctionObject function) {
  exists(Call superInvocation, Call methodCall, Attribute attribute, GlobalVariable superReference |
    methodCall.getScope() = function.getFunction() and
    methodCall.getFunc() = attribute and
    attribute.getObject() = superInvocation and
    attribute.getName() = function.getName() and
    superInvocation.getFunc() = superReference.getAnAccess() and
    superReference.getId() = "super"
  )
}

/**
 * Defines attribute names that should be excluded from conflict detection.
 */
predicate is_attribute_exempt(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, ClassObject baseClass1, ClassObject baseClass2, 
  string conflictingAttribute, int position1, int position2, 
  Object attributeInBase1, Object attributeInBase2
where
  // Ensure we have distinct base classes with ordered inheritance positions
  derivedClass.getBaseType(position1) = baseClass1 and
  derivedClass.getBaseType(position2) = baseClass2 and
  position1 < position2 and
  
  // Find the same attribute defined in both base classes
  attributeInBase1 = baseClass1.lookupAttribute(conflictingAttribute) and
  attributeInBase2 = baseClass2.lookupAttribute(conflictingAttribute) and
  attributeInBase1 != attributeInBase2 and
  
  // Exclude special dunder methods from conflict detection
  not conflictingAttribute.matches("\\_\\_%\\_\\_") and
  
  // Skip cases where the first base class uses super() (safe overriding)
  not uses_super_call(attributeInBase1) and
  
  // Ignore trivial functions in the second base class
  not is_trivial_function(attributeInBase2) and
  
  // Exclude attributes that are exempt from conflict detection
  not is_attribute_exempt(conflictingAttribute) and
  
  // Verify no override relationship exists between attributes
  not attributeInBase1.overrides(attributeInBase2) and
  not attributeInBase2.overrides(attributeInBase1) and
  
  // Ensure the derived class doesn't explicitly declare the attribute
  not derivedClass.declaresAttribute(conflictingAttribute)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttribute + "': $@ and $@.", 
  attributeInBase1, attributeInBase1.toString(), 
  attributeInBase2, attributeInBase2.toString()