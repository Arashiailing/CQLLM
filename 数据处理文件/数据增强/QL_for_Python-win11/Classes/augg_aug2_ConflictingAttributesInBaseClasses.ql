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
 * Identifies functions that perform no operations beyond pass statements and docstrings.
 */
predicate is_empty_function(PyFunctionObject funcObj) {
  not exists(Stmt statement | statement.getScope() = funcObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Determines if a function explicitly invokes parent class methods via super().
 */
predicate invokes_super(FunctionObject funcObj) {
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
 * Defines attribute names exempt from conflict detection due to special cases.
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject subClass, ClassObject firstBase, ClassObject secondBase, 
  string attributeName, int firstIndex, int secondIndex, 
  Object attrInFirstBase, Object attrInSecondBase
where
  // Ensure distinct base classes with ordered inheritance positions
  subClass.getBaseType(firstIndex) = firstBase and
  subClass.getBaseType(secondIndex) = secondBase and
  firstIndex < secondIndex and
  
  // Identify conflicting attributes in base classes
  attrInFirstBase = firstBase.lookupAttribute(attributeName) and
  attrInSecondBase = secondBase.lookupAttribute(attributeName) and
  attrInFirstBase != attrInSecondBase and
  
  // Exclude special methods (dunder methods)
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  // Skip cases where super() is called (safe overriding)
  not invokes_super(attrInFirstBase) and
  
  // Ignore empty functions in second base class
  not is_empty_function(attrInSecondBase) and
  
  // Exclude exempted attribute names
  not is_exempt_attribute(attributeName) and
  
  // Verify no override relationship exists between attributes
  not attrInFirstBase.overrides(attrInSecondBase) and
  not attrInSecondBase.overrides(attrInFirstBase) and
  
  // Ensure subclass doesn't explicitly declare the attribute
  not subClass.declaresAttribute(attributeName)
select subClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attrInFirstBase, attrInFirstBase.toString(), 
  attrInSecondBase, attrInSecondBase.toString()