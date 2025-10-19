/**
 * @name Conflicting attributes in base classes
 * @description Identifies when a class inherits from multiple base classes that define the same attribute,
 *              potentially causing unexpected behavior due to attribute resolution conflicts.
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
predicate is_empty_function(PyFunctionObject methodObj) {
  not exists(Stmt statement | statement.getScope() = methodObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = methodObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates the method properly handles inheritance by calling
 * the parent class's implementation.
 */
predicate has_super_call(FunctionObject methodObj) {
  exists(Call superInvocation, Call methodInvocation, Attribute attributeRef, GlobalVariable superGlobal |
    methodInvocation.getScope() = methodObj.getFunction() and
    methodInvocation.getFunc() = attributeRef and
    attributeRef.getObject() = superInvocation and
    attributeRef.getName() = methodObj.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection.
 * Currently only includes 'process_request' due to special handling
 * in Python's socketserver module (per documentation).
 */
predicate is_exempt_attribute(string attrName) {
  attrName = "process_request"  // Recommended in Python docs for async mixins
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
  baseIndex1 < baseIndex2 and
  
  // Locate conflicting attributes in different base classes
  attrInBase1 = baseClass1.lookupAttribute(attributeName) and
  attrInBase2 = baseClass2.lookupAttribute(attributeName) and
  attrInBase1 != attrInBase2 and
  
  // Filter out special method names and exempt attributes
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // Exclude cases where inheritance is properly handled
  (
    not has_super_call(attrInBase1) and
    not is_empty_function(attrInBase2) and
    not attrInBase1.overrides(attrInBase2) and
    not attrInBase2.overrides(attrInBase1)
  ) and
  
  // Ensure the derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(attributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()