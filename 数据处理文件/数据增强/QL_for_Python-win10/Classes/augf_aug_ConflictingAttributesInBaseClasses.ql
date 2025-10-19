/**
 * @name Conflicting attributes in base classes
 * @description Detects classes that inherit from multiple base classes where more than one base class defines the same attribute. Such conflicts can lead to unexpected behavior due to attribute resolution ambiguity.
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

// Determines if a Python function implementation is effectively empty
predicate is_empty_implementation(PyFunctionObject function) {
  // Verifies the function body contains only pass statements or docstrings
  not exists(Stmt stmt | stmt.getScope() = function.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

// Checks if a function explicitly invokes super() for method resolution
predicate invokes_super(FunctionObject function) {
  // Identifies super() calls within the function body
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = function.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = function.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/** Identifies attribute names exempt from conflict detection */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for process_request as documented in Python's socketserver module:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttributeName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attributeFromFirstBase, 
  Object attributeFromSecondBase
where
  // Establish inheritance relationships between derived class and its base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  // Ensure base classes are distinct and ordered by inheritance position
  firstBaseIndex < secondBaseIndex and
  attributeFromFirstBase != attributeFromSecondBase and
  // Locate conflicting attributes in different base classes
  attributeFromFirstBase = firstBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeFromSecondBase = secondBaseClass.lookupAttribute(conflictingAttributeName) and
  // Exclude special double-underscore methods from analysis
  not conflictingAttributeName.matches("\\_\\_%\\_\\_") and
  // Skip conflicts where one base class properly handles method resolution
  not invokes_super(attributeFromFirstBase) and
  // Ignore trivial implementations in the second base class
  not is_empty_implementation(attributeFromSecondBase) and
  // Exclude known exempt attributes
  not is_exempt_attribute(conflictingAttributeName) and
  // Verify no override relationship exists between conflicting attributes
  not attributeFromFirstBase.overrides(attributeFromSecondBase) and
  not attributeFromSecondBase.overrides(attributeFromFirstBase) and
  // Ensure derived class doesn't explicitly declare the conflicting attribute
  not derivedClass.declaresAttribute(conflictingAttributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttributeName + "': $@ and $@.", 
  attributeFromFirstBase, attributeFromFirstBase.toString(), 
  attributeFromSecondBase, attributeFromSecondBase.toString()