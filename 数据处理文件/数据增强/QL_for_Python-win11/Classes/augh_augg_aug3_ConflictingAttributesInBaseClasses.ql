/**
 * @name Conflicting attributes in base classes
 * @description Detects classes inheriting from multiple base classes defining the same attribute,
 *              which may cause unexpected behavior due to attribute resolution conflicts.
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
 * Determines if a function implementation is effectively empty.
 * A function is considered empty if its body contains only pass statements
 * or its docstring expression.
 */
predicate isEffectivelyEmptyFunction(PyFunctionObject funcObj) {
  not exists(Stmt stmt | stmt.getScope() = funcObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates proper inheritance handling by invoking the parent class's implementation.
 */
predicate containsSuperCall(FunctionObject funcObj) {
  exists(Call superCall, Call methodCall, Attribute attrRef, GlobalVariable superGlobal |
    methodCall.getScope() = funcObj.getFunction() and
    methodCall.getFunc() = attrRef and
    attrRef.getObject() = superCall and
    attrRef.getName() = funcObj.getName() and
    superCall.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Specifies attribute names exempt from conflict detection.
 * Currently only 'process_request' is exempt due to special handling
 * in Python's socketserver module (as per documentation).
 */
predicate isExemptAttribute(string exemptAttr) {
  exemptAttr = "process_request"  // Recommended in Python docs for async mixins
}

from
  ClassObject childClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string conflictingAttr, 
  int baseIndex1, 
  int baseIndex2, 
  Object attributeInBase1, 
  Object attributeInBase2
where
  // Establish inheritance relationships with distinct base classes
  childClass.getBaseType(baseIndex1) = baseClass1 and
  childClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  
  // Locate conflicting attributes in different base classes
  attributeInBase1 = baseClass1.lookupAttribute(conflictingAttr) and
  attributeInBase2 = baseClass2.lookupAttribute(conflictingAttr) and
  attributeInBase1 != attributeInBase2 and
  
  // Filter out special method names and exempt attributes
  not conflictingAttr.matches("\\_\\_%\\_\\_") and
  not isExemptAttribute(conflictingAttr) and
  
  // Exclude cases where inheritance is properly handled
  not containsSuperCall(attributeInBase1) and
  not isEffectivelyEmptyFunction(attributeInBase2) and
  not attributeInBase1.overrides(attributeInBase2) and
  not attributeInBase2.overrides(attributeInBase1) and
  
  // Ensure the derived class doesn't resolve the conflict
  not childClass.declaresAttribute(conflictingAttr)
select 
  childClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttr + "': $@ and $@.", 
  attributeInBase1, attributeInBase1.toString(), 
  attributeInBase2, attributeInBase2.toString()