/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes that define the same attribute, which may cause unexpected behavior due to attribute resolution ambiguity.
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

// Evaluates whether a Python function contains only trivial implementation elements
predicate has_trivial_implementation(PyFunctionObject function) {
  // Confirms the function body consists solely of pass statements or docstrings
  not exists(Stmt stmt | stmt.getScope() = function.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

// Determines if a function utilizes super() for proper method resolution order
predicate uses_super_resolution(FunctionObject function) {
  // Detects super() method calls within the function implementation
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = function.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = function.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/** Defines attributes that should be excluded from conflict analysis */
predicate is_attribute_exempted(string attributeName) {
  /*
   * Special exemption for process_request based on Python's socketserver documentation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttrName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attrInFirstBase, 
  Object attrInSecondBase
where
  // Establish inheritance hierarchy with distinct base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Identify attribute definitions in both base classes
  attrInFirstBase = firstBaseClass.lookupAttribute(conflictingAttrName) and
  attrInSecondBase = secondBaseClass.lookupAttribute(conflictingAttrName) and
  attrInFirstBase != attrInSecondBase and
  
  // Apply filtering conditions to reduce false positives
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and
  not is_attribute_exempted(conflictingAttrName) and
  not derivedClass.declaresAttribute(conflictingAttrName) and
  
  // Exclude cases where proper method resolution is implemented
  not uses_super_resolution(attrInFirstBase) and
  not has_trivial_implementation(attrInSecondBase) and
  
  // Ensure no override relationship exists between the attributes
  not attrInFirstBase.overrides(attrInSecondBase) and
  not attrInSecondBase.overrides(attrInFirstBase)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  attrInFirstBase, attrInFirstBase.toString(), 
  attrInSecondBase, attrInSecondBase.toString()