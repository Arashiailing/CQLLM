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
 * containing only pass statements and its docstring.
 */
predicate is_empty_function(PyFunctionObject functionObject) {
  not exists(Stmt statement | statement.getScope() = functionObject.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = functionObject.getFunction().getDocString()
  )
}

/**
 * Identifies functions that explicitly invoke parent class methods
 * using super() calls.
 */
predicate has_super_call(FunctionObject functionObject) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = functionObject.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = functionObject.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Defines attribute names that should be excluded from conflict detection
 * due to established framework patterns.
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject childClass, ClassObject firstParentClass, ClassObject secondParentClass, 
  string attributeName, int firstParentIndex, int secondParentIndex, 
  Object firstAttribute, Object secondAttribute
where
  // Establish inheritance relationship with ordered base classes
  childClass.getBaseType(firstParentIndex) = firstParentClass and
  childClass.getBaseType(secondParentIndex) = secondParentClass and
  firstParentIndex < secondParentIndex and
  
  // Identify conflicting attributes in parent classes
  firstAttribute = firstParentClass.lookupAttribute(attributeName) and
  secondAttribute = secondParentClass.lookupAttribute(attributeName) and
  firstAttribute != secondAttribute and
  
  // Exclude special methods (dunder methods)
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  // Filter safe overriding scenarios
  not has_super_call(firstAttribute) and
  
  // Ignore trivial implementations in second parent
  not is_empty_function(secondAttribute) and
  
  // Skip exempted attributes
  not is_exempt_attribute(attributeName) and
  
  // Verify no override relationship exists between attributes
  not firstAttribute.overrides(secondAttribute) and
  not secondAttribute.overrides(firstAttribute) and
  
  // Ensure child class doesn't explicitly declare the attribute
  not childClass.declaresAttribute(attributeName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  firstAttribute, firstAttribute.toString(), 
  secondAttribute, secondAttribute.toString()