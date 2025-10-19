/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting multiple base classes with duplicate attribute definitions,
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
predicate is_empty_function(PyFunctionObject funcImpl) {
  not exists(Stmt stmt | stmt.getScope() = funcImpl.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = funcImpl.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates the method properly handles inheritance by calling
 * the parent class's implementation.
 */
predicate has_super_call(FunctionObject methodImpl) {
  exists(Call superCall, Call methodCall, Attribute attrRef, GlobalVariable superVar |
    methodCall.getScope() = methodImpl.getFunction() and
    methodCall.getFunc() = attrRef and
    attrRef.getObject() = superCall and
    attrRef.getName() = methodImpl.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Specifies attribute names exempt from conflict detection.
 * Currently only includes 'process_request' due to special handling
 * in Python's socketserver module (per documentation).
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"  // Recommended in Python docs for async mixins
}

from
  ClassObject derivedClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string attributeName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attributeInFirstBase, 
  Object attributeInSecondBase
where
  // Establish inheritance relationships
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Identify conflicting attributes in base classes
  attributeInFirstBase = firstBaseClass.lookupAttribute(attributeName) and
  attributeInSecondBase = secondBaseClass.lookupAttribute(attributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Filter special methods and exempt attributes
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // Exclude properly handled inheritance cases
  not has_super_call(attributeInFirstBase) and
  not is_empty_function(attributeInSecondBase) and
  not attributeInFirstBase.overrides(attributeInSecondBase) and
  not attributeInSecondBase.overrides(attributeInFirstBase) and
  
  // Ensure derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(attributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()