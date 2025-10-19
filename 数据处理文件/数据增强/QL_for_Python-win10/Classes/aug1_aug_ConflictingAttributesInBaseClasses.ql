/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes where the same attribute is defined in more than one base. Such conflicts may cause unexpected behavior due to attribute resolution ambiguity.
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

/** Checks if a function implementation is effectively empty (only pass/docstring) */
predicate is_empty_implementation(PyFunctionObject func) {
  // Verify function body contains only pass statements or docstrings
  not exists(Stmt s | s.getScope() = func.getFunction() |
    not s instanceof Pass and 
    not s.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/** Determines if a function explicitly invokes super() for method resolution */
predicate invokes_super(FunctionObject func) {
  // Identify super() calls within function body
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/** Identifies attributes exempt from conflict detection */
predicate is_exempt_attribute(string attrName) {
  /*
   * Exemption for process_request as documented in Python's socketserver module:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject base1, 
  ClassObject base2, 
  string attrName, 
  int idx1, 
  int idx2, 
  Object attrInBase1, 
  Object attrInBase2
where
  // Establish inheritance relationships with distinct base classes
  derivedClass.getBaseType(idx1) = base1 and
  derivedClass.getBaseType(idx2) = base2 and
  idx1 < idx2 and
  // Locate conflicting attributes in base classes
  attrInBase1 = base1.lookupAttribute(attrName) and
  attrInBase2 = base2.lookupAttribute(attrName) and
  attrInBase1 != attrInBase2 and
  // Exclude special dunder methods from analysis
  not attrName.matches("\\_\\_%\\_\\_") and
  // Skip conflicts where first base properly handles method resolution
  not invokes_super(attrInBase1) and
  // Ignore trivial implementations in second base class
  not is_empty_implementation(attrInBase2) and
  // Exclude known exempt attributes
  not is_exempt_attribute(attrName) and
  // Verify no override relationship between conflicting attributes
  not attrInBase1.overrides(attrInBase2) and
  not attrInBase2.overrides(attrInBase1) and
  // Ensure derived class doesn't declare the conflicting attribute
  not derivedClass.declaresAttribute(attrName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()