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
  ClassObject derivedClass, 
  ClassObject firstBase, 
  ClassObject secondBase, 
  string attributeName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attributeInFirstBase, 
  Object attributeInSecondBase
where
  // Establish inheritance relationships with distinct base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBase and
  derivedClass.getBaseType(secondBaseIndex) = secondBase and
  firstBaseIndex < secondBaseIndex and
  
  // Locate conflicting attributes in different base classes
  attributeInFirstBase = firstBase.lookupAttribute(attributeName) and
  attributeInSecondBase = secondBase.lookupAttribute(attributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Filter special method names and exempt attributes
  not attributeName.matches("\\_\\_%\\_\\_") and
  not isExemptAttribute(attributeName) and
  
  // Exclude cases where inheritance is properly handled
  (not containsSuperCall(attributeInFirstBase) and
   not isEffectivelyEmptyFunction(attributeInSecondBase) and
   not attributeInFirstBase.overrides(attributeInSecondBase) and
   not attributeInSecondBase.overrides(attributeInFirstBase)) and
  
  // Ensure the derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(attributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()