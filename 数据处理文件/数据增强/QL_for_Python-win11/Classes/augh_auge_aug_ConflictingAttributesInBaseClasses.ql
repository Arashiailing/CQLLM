/**
 * @name Conflicting attributes in base classes
 * @description Detects classes inheriting from multiple base classes where identical attributes are defined in more than one base. This ambiguity can cause unexpected behavior during attribute resolution.
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

// Determines if a Python function contains only trivial implementation elements
predicate is_empty_implementation(PyFunctionObject functionObj) {
  // Checks if function body consists solely of pass statements or docstrings
  not exists(Stmt stmt | stmt.getScope() = functionObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

// Checks if a method properly utilizes super() for method resolution order
predicate invokes_super(FunctionObject functionObj) {
  // Detects super() calls targeting the current method name
  exists(Call superCallExpr, Call methodCallExpr, Attribute attrRef, GlobalVariable superVar |
    methodCallExpr.getScope() = functionObj.getFunction() and
    methodCallExpr.getFunc() = attrRef and
    attrRef.getObject() = superCallExpr and
    attrRef.getName() = functionObj.getName() and
    superCallExpr.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/** Defines attributes excluded from conflict analysis */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for process_request per Python socketserver documentation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int baseIndex1, 
  int baseIndex2, 
  Object attrInBase1, 
  Object attrInBase2
where
  // Establish inheritance relationships with distinct base classes
  derivedClass.getBaseType(baseIndex1) = baseClass1 and
  derivedClass.getBaseType(baseIndex2) = baseClass2 and
  // Ensure base classes are ordered by inheritance position
  baseIndex1 < baseIndex2 and
  // Locate identical attributes in different base classes
  attrInBase1 = baseClass1.lookupAttribute(attributeName) and
  attrInBase2 = baseClass2.lookupAttribute(attributeName) and
  // Verify attributes are distinct objects
  attrInBase1 != attrInBase2 and
  // Exclude special double-underscore methods
  not attributeName.matches("\\_\\_%\\_\\_") and
  // Exclude known exempt attributes
  not is_exempt_attribute(attributeName) and
  // Confirm derived class doesn't explicitly declare attribute
  not derivedClass.declaresAttribute(attributeName) and
  // Skip conflicts where first base handles method resolution
  not invokes_super(attrInBase1) and
  // Ignore trivial implementations in second base
  not is_empty_implementation(attrInBase2) and
  // Ensure no override relationship between attributes
  not attrInBase1.overrides(attrInBase2) and
  not attrInBase2.overrides(attrInBase1)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()