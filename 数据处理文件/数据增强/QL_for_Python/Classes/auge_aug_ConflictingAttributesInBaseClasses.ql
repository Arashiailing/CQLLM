/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes where identical attributes are defined in more than one base. This ambiguity can cause unexpected behavior during attribute resolution.
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
predicate is_empty_implementation(PyFunctionObject func) {
  // Checks if function body consists solely of pass statements or docstrings
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

// Determines if a method properly utilizes super() for method resolution order
predicate invokes_super(FunctionObject func) {
  // Detects super() calls targeting the current method name
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
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
  ClassObject firstBase, 
  ClassObject secondBase, 
  string conflictingAttr, 
  int idx1, 
  int idx2, 
  Object attrInFirstBase, 
  Object attrInSecondBase
where
  // Establish inheritance relationships with distinct base classes
  derivedClass.getBaseType(idx1) = firstBase and
  derivedClass.getBaseType(idx2) = secondBase and
  // Ensure base classes are ordered by inheritance position
  idx1 < idx2 and
  // Locate identical attributes in different base classes
  attrInFirstBase = firstBase.lookupAttribute(conflictingAttr) and
  attrInSecondBase = secondBase.lookupAttribute(conflictingAttr) and
  // Verify attributes are distinct objects
  attrInFirstBase != attrInSecondBase and
  // Exclude special double-underscore methods
  not conflictingAttr.matches("\\_\\_%\\_\\_") and
  // Skip conflicts where first base handles method resolution
  not invokes_super(attrInFirstBase) and
  // Ignore trivial implementations in second base
  not is_empty_implementation(attrInSecondBase) and
  // Exclude known exempt attributes
  not is_exempt_attribute(conflictingAttr) and
  // Ensure no override relationship between attributes
  not attrInFirstBase.overrides(attrInSecondBase) and
  not attrInSecondBase.overrides(attrInFirstBase) and
  // Confirm derived class doesn't explicitly declare attribute
  not derivedClass.declaresAttribute(conflictingAttr)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttr + "': $@ and $@.", 
  attrInFirstBase, attrInFirstBase.toString(), 
  attrInSecondBase, attrInSecondBase.toString()