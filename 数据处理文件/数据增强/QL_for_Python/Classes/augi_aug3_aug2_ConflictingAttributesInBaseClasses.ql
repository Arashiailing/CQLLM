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
 * Determines if a function implementation is effectively empty,
 * containing only pass statements and a docstring.
 */
predicate is_empty_function(PyFunctionObject functionObj) {
  not exists(Stmt codeStatement | codeStatement.getScope() = functionObj.getFunction() |
    not codeStatement instanceof Pass and 
    not codeStatement.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function implementation includes a call to super()
 * to invoke a parent class method with the same name.
 */
predicate has_super_call(FunctionObject functionObj) {
  exists(Call superInvocation, Call methodInvocation, Attribute attribute, GlobalVariable superGlobalVar |
    methodInvocation.getScope() = functionObj.getFunction() and
    methodInvocation.getFunc() = attribute and
    attribute.getObject() = superInvocation and
    attribute.getName() = functionObj.getName() and
    superInvocation.getFunc() = superGlobalVar.getAnAccess() and
    superGlobalVar.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection
 * due to specific design patterns or library recommendations.
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject childClass, ClassObject primaryBase, ClassObject secondaryBase, 
  string attributeName, int primaryIndex, int secondaryIndex, 
  Object primaryAttribute, Object secondaryAttribute
where
  // Ensure ordered inheritance from distinct base classes
  childClass.getBaseType(primaryIndex) = primaryBase and
  childClass.getBaseType(secondaryIndex) = secondaryBase and
  primaryIndex < secondaryIndex and
  
  // Locate conflicting attributes in base classes
  primaryAttribute = primaryBase.lookupAttribute(attributeName) and
  secondaryAttribute = secondaryBase.lookupAttribute(attributeName) and
  primaryAttribute != secondaryAttribute and
  
  // Filter out special methods (dunder methods)
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  // Exclude cases where the first attribute safely uses super()
  not has_super_call(primaryAttribute) and
  
  // Ignore empty implementations in the second base class
  not is_empty_function(secondaryAttribute) and
  
  // Skip exempted attribute names
  not is_exempt_attribute(attributeName) and
  
  // Verify no override relationship exists between attributes
  not primaryAttribute.overrides(secondaryAttribute) and
  not secondaryAttribute.overrides(primaryAttribute) and
  
  // Ensure the child class doesn't explicitly declare the attribute
  not childClass.declaresAttribute(attributeName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  primaryAttribute, primaryAttribute.toString(), 
  secondaryAttribute, secondaryAttribute.toString()