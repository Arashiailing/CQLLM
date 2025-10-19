/**
 * @name Conflicting attributes in base classes
 * @description Finds classes inheriting multiple base classes defining the same attribute,
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
 * Checks whether a function implementation is effectively empty.
 * A function is considered empty if its body contains only pass statements
 * or its docstring expression.
 */
predicate is_empty_function(PyFunctionObject functionObj) {
  not exists(Stmt statement | statement.getScope() = functionObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Determines if a function contains a super() call for its own name.
 * This indicates proper inheritance handling by invoking the parent class's implementation.
 */
predicate has_super_call(FunctionObject functionObj) {
  exists(Call superInvocation, Call methodInvocation, Attribute attributeRef, GlobalVariable superGlobal |
    methodInvocation.getScope() = functionObj.getFunction() and
    methodInvocation.getFunc() = attributeRef and
    attributeRef.getObject() = superInvocation and
    attributeRef.getName() = functionObj.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Specifies attribute names exempt from conflict detection.
 * Currently only 'process_request' is exempt due to special handling
 * in Python's socketserver module (as per documentation).
 */
predicate is_exempt_attribute(string exemptAttrName) {
  exemptAttrName = "process_request"  // Recommended in Python docs for async mixins
}

from
  ClassObject derivedClass, 
  ClassObject parentClass1, 
  ClassObject parentClass2, 
  string attributeName, 
  int index1, 
  int index2, 
  Object attrInBase1, 
  Object attrInBase2
where
  // Establish inheritance relationships with distinct base classes
  derivedClass.getBaseType(index1) = parentClass1 and
  derivedClass.getBaseType(index2) = parentClass2 and
  index1 < index2 and
  
  // Locate conflicting attributes in different base classes
  attrInBase1 = parentClass1.lookupAttribute(attributeName) and
  attrInBase2 = parentClass2.lookupAttribute(attributeName) and
  attrInBase1 != attrInBase2 and
  
  // Filter out special method names and exempt attributes
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // Exclude cases where inheritance is properly handled
  not has_super_call(attrInBase1) and
  not is_empty_function(attrInBase2) and
  not attrInBase1.overrides(attrInBase2) and
  not attrInBase2.overrides(attrInBase1) and
  
  // Ensure the derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(attributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attrInBase1, attrInBase1.toString(), 
  attrInBase2, attrInBase2.toString()