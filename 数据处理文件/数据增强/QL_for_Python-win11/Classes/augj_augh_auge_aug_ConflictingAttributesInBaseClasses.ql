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

// Checks if a function contains only trivial implementation (pass/docstring)
predicate is_empty_implementation(PyFunctionObject funcObj) {
  not exists(Stmt bodyStmt | bodyStmt.getScope() = funcObj.getFunction() |
    not bodyStmt instanceof Pass and 
    not bodyStmt.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

// Verifies if a method properly utilizes super() for method resolution
predicate invokes_super(FunctionObject funcObj) {
  exists(Call superCall, Call methodCall, Attribute attributeRef, GlobalVariable superGlobal |
    methodCall.getScope() = funcObj.getFunction() and
    methodCall.getFunc() = attributeRef and
    attributeRef.getObject() = superCall and
    attributeRef.getName() = funcObj.getName() and
    superCall.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/** Defines attributes excluded from conflict analysis */
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
  string attributeName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attrInFirstBase, 
  Object attrInSecondBase
where
  /* Establish inheritance relationships with distinct base classes */
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  /* Ensure base classes are ordered by inheritance position */
  firstBaseIndex < secondBaseIndex and
  /* Locate identical attributes in different base classes */
  attrInFirstBase = firstBaseClass.lookupAttribute(attributeName) and
  attrInSecondBase = secondBaseClass.lookupAttribute(attributeName) and
  /* Verify attributes are distinct objects */
  attrInFirstBase != attrInSecondBase and
  /* Exclude special double-underscore methods */
  not attributeName.matches("\\_\\_%\\_\\_") and
  /* Exclude known exempt attributes */
  not is_exempt_attribute(attributeName) and
  /* Confirm derived class doesn't explicitly declare attribute */
  not derivedClass.declaresAttribute(attributeName) and
  /* Skip conflicts where first base handles method resolution */
  not invokes_super(attrInFirstBase) and
  /* Ignore trivial implementations in second base */
  not is_empty_implementation(attrInSecondBase) and
  /* Ensure no override relationship between attributes */
  not attrInFirstBase.overrides(attrInSecondBase) and
  not attrInSecondBase.overrides(attrInFirstBase)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attrInFirstBase, attrInFirstBase.toString(), 
  attrInSecondBase, attrInSecondBase.toString()