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
 * Determines if a function contains only pass statements and a docstring.
 */
predicate is_empty_function(PyFunctionObject funcObj) {
  not exists(Stmt stmt | stmt.getScope() = funcObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function invokes a parent method via super() call.
 */
predicate has_super_call(FunctionObject funcObj) {
  exists(Call superInvoke, Call methodInvoke, Attribute attribute, GlobalVariable superGlobal |
    methodInvoke.getScope() = funcObj.getFunction() and
    methodInvoke.getFunc() = attribute and
    attribute.getObject() = superInvoke and
    attribute.getName() = funcObj.getName() and
    superInvoke.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Identifies attribute names excluded from conflict detection.
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject childClass, ClassObject baseClass1, ClassObject baseClass2, 
  string attributeName, int index1, int index2, 
  Object attribute1, Object attribute2
where
  // Establish inheritance hierarchy with ordered base classes
  childClass.getBaseType(index1) = baseClass1 and
  childClass.getBaseType(index2) = baseClass2 and
  index1 < index2 and
  
  // Identify conflicting attributes in base classes
  attribute1 = baseClass1.lookupAttribute(attributeName) and
  attribute2 = baseClass2.lookupAttribute(attributeName) and
  attribute1 != attribute2 and
  
  // Exclude special methods (dunder methods)
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  // Filter safe overriding scenarios
  not has_super_call(attribute1) and
  
  // Ignore trivial implementations in second base class
  not is_empty_function(attribute2) and
  
  // Skip exempted attribute names
  not is_exempt_attribute(attributeName) and
  
  // Verify no override relationship exists
  not attribute1.overrides(attribute2) and
  not attribute2.overrides(attribute1) and
  
  // Ensure child class doesn't explicitly declare the attribute
  not childClass.declaresAttribute(attributeName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attribute1, attribute1.toString(), 
  attribute2, attribute2.toString()