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
  ClassObject currentClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int baseIndex1, 
  int baseIndex2, 
  Object attributeInBase1, 
  Object attributeInBase2
where
  // Establish inheritance relationships between current class and base classes
  currentClass.getBaseType(baseIndex1) = baseClass1 and
  currentClass.getBaseType(baseIndex2) = baseClass2 and
  // Ensure base classes are distinct and ordered by inheritance position
  baseIndex1 < baseIndex2 and
  attributeInBase1 != attributeInBase2 and
  // Locate conflicting attributes in different base classes
  attributeInBase1 = baseClass1.lookupAttribute(attributeName) and
  attributeInBase2 = baseClass2.lookupAttribute(attributeName) and
  // Exclude special double-underscore methods from analysis
  not attributeName.matches("\\_\\_%\\_\\_") and
  // Skip conflicts where one base class properly handles method resolution
  not invokes_super(attributeInBase1) and
  // Ignore trivial implementations in the second base class
  not is_empty_implementation(attributeInBase2) and
  // Exclude known exempt attributes
  not is_exempt_attribute(attributeName) and
  // Verify no override relationship exists between conflicting attributes
  not attributeInBase1.overrides(attributeInBase2) and
  not attributeInBase2.overrides(attributeInBase1) and
  // Ensure current class doesn't explicitly declare the conflicting attribute
  not currentClass.declaresAttribute(attributeName)
select currentClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBase1, attributeInBase1.toString(), 
  attributeInBase2, attributeInBase2.toString()