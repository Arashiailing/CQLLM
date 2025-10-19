/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting multiple base classes with duplicate attribute definitions,
 *              which can lead to unpredictable behavior from attribute resolution conflicts.
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
 * Determines whether a function implementation contains no meaningful logic.
 * A function qualifies as empty if its body consists solely of pass statements
 * or its associated docstring expression.
 */
predicate is_empty_function(PyFunctionObject functionImpl) {
  not exists(Stmt stmt | stmt.getScope() = functionImpl.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = functionImpl.getFunction().getDocString()
  )
}

/**
 * Checks if a method properly handles inheritance by invoking parent's implementation
 * through a super() call matching its own name.
 */
predicate has_super_call(FunctionObject methodImpl) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = methodImpl.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = methodImpl.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Defines attribute names excluded from conflict detection.
 * Currently only 'process_request' is exempt due to special handling
 * requirements in Python's socketserver module (per official documentation).
 */
predicate is_exempt_attribute(string attrName) {
  attrName = "process_request"  // Documented exception for async mixins
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int baseIndex1, 
  int baseIndex2, 
  Object attributeInBase1, 
  Object attributeInBase2
where
  // Establish distinct inheritance relationships
  derivedClass.getBaseType(baseIndex1) = baseClass1 and
  derivedClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  
  // Identify conflicting attributes in separate base classes
  attributeInBase1 = baseClass1.lookupAttribute(attributeName) and
  attributeInBase2 = baseClass2.lookupAttribute(attributeName) and
  attributeInBase1 != attributeInBase2 and
  
  // Exclude special methods and exempted attributes
  not attributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(attributeName) and
  
  // Filter cases where inheritance is properly managed
  (
    not has_super_call(attributeInBase1) and
    not is_empty_function(attributeInBase2) and
    not attributeInBase1.overrides(attributeInBase2) and
    not attributeInBase2.overrides(attributeInBase1)
  ) and
  
  // Ensure derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(attributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBase1, attributeInBase1.toString(), 
  attributeInBase2, attributeInBase2.toString()