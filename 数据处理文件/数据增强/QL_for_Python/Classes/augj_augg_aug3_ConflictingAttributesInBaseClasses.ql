/**
 * @name Conflicting attributes in base classes
 * @description Detects classes inheriting from multiple base classes that define the same attribute,
 *              which may lead to unexpected behavior due to attribute resolution conflicts.
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
predicate isEffectivelyEmptyFunction(PyFunctionObject funcImpl) {
  not exists(Stmt statement | statement.getScope() = funcImpl.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = funcImpl.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates proper inheritance handling by invoking the parent class's implementation.
 */
predicate containsSuperCall(FunctionObject funcImpl) {
  exists(Call superInvocation, Call methodInvocation, Attribute attributeRef, GlobalVariable superGlobal |
    methodInvocation.getScope() = funcImpl.getFunction() and
    methodInvocation.getFunc() = attributeRef and
    attributeRef.getObject() = superInvocation and
    attributeRef.getName() = funcImpl.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Defines attribute names that are exempt from conflict detection.
 * Currently only 'process_request' is exempt due to special handling
 * in Python's socketserver module (as per documentation).
 */
predicate isExemptAttribute(string exemptAttrName) {
  exemptAttrName = "process_request"  // Recommended in Python docs for async mixins
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
  // Establish inheritance relationships with distinct base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Identify conflicting attributes in different base classes
  attrInFirstBase = firstBaseClass.lookupAttribute(conflictingAttrName) and
  attrInSecondBase = secondBaseClass.lookupAttribute(conflictingAttrName) and
  attrInFirstBase != attrInSecondBase and
  
  // Filter out special method names and exempt attributes
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and
  not isExemptAttribute(conflictingAttrName) and
  
  // Exclude cases where inheritance is properly handled
  not containsSuperCall(attrInFirstBase) and
  not isEffectivelyEmptyFunction(attrInSecondBase) and
  not attrInFirstBase.overrides(attrInSecondBase) and
  not attrInSecondBase.overrides(attrInFirstBase) and
  
  // Ensure the derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(conflictingAttrName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  attrInFirstBase, attrInFirstBase.toString(), 
  attrInSecondBase, attrInSecondBase.toString()