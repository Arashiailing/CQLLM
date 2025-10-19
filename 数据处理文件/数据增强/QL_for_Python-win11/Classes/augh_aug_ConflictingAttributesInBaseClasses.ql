/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes where identical attributes are defined in more than one base. This creates ambiguity in attribute resolution and may cause unexpected runtime behavior.
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

// Determines if a function implementation contains only pass statements or docstrings
predicate is_empty_implementation(PyFunctionObject func) {
  // Checks that function body contains no meaningful statements beyond pass/docstring
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

// Verifies if a function contains explicit super() calls for method resolution
predicate invokes_super(FunctionObject method) {
  // Detects super() method calls matching the current function name
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = method.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = method.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/** Defines attributes exempt from conflict detection rules */
predicate is_exempt_attribute(string attrName) {
  /*
   * Exemption for process_request per Python socketserver documentation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string attrName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object firstBaseAttr, 
  Object secondBaseAttr
where
  // Establish inheritance hierarchy with distinct base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  firstBaseAttr != secondBaseAttr and
  // Identify conflicting attributes across base classes
  firstBaseAttr = firstBaseClass.lookupAttribute(attrName) and
  secondBaseAttr = secondBaseClass.lookupAttribute(attrName) and
  // Exclude special methods from analysis
  not attrName.matches("\\_\\_%\\_\\_") and
  // Filter cases where method resolution is properly handled
  not invokes_super(firstBaseAttr) and
  // Ignore trivial implementations in second base class
  not is_empty_implementation(secondBaseAttr) and
  // Skip known exempt attributes
  not is_exempt_attribute(attrName) and
  // Verify no override relationship exists between attributes
  not firstBaseAttr.overrides(secondBaseAttr) and
  not secondBaseAttr.overrides(firstBaseAttr) and
  // Ensure derived class doesn't explicitly declare the attribute
  not derivedClass.declaresAttribute(attrName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  firstBaseAttr, firstBaseAttr.toString(), 
  secondBaseAttr, secondBaseAttr.toString()