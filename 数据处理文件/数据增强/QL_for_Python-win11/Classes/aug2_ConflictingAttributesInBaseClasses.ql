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
 * Determines if a Python function performs no operations beyond pass statements and docstrings.
 */
predicate does_nothing(PyFunctionObject funcObj) {
  not exists(Stmt statement | statement.getScope() = funcObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly calls super() to invoke parent class methods.
 */
predicate calls_super(FunctionObject funcObj) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = funcObj.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = funcObj.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection due to special cases.
 */
predicate allowed(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject childClass, ClassObject baseClass1, ClassObject baseClass2, 
  string attributeName, int index1, int index2, 
  Object attrInBase1, Object attrInBase2
where
  // Ensure two distinct base classes with ordered inheritance positions
  childClass.getBaseType(index1) = baseClass1 and
  childClass.getBaseType(index2) = baseClass2 and
  index1 < index2 and
  
  // Locate conflicting attributes in base classes
  attrInBase1 = baseClass1.lookupAttribute(attributeName) and
  attrInBase2 = baseClass2.lookupAttribute(attributeName) and
  attrInBase1 != attrInBase2 and
  
  // Filter out special methods (dunder methods)
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  // Exclude cases where super() is called (safe overriding)
  not calls_super(attrInBase1) and
  
  // Ignore empty functions in second base class
  not does_nothing(attrInBase2) and
  
  // Skip exempted attribute names
  not allowed(attributeName) and
  
  // Ensure no override relationship exists between attributes
  not attrInBase1.overrides(attrInBase2) and
  not attrInBase2.overrides(attrInBase1) and
  
  // Verify child class doesn't explicitly declare the attribute
  not childClass.declaresAttribute(attributeName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()