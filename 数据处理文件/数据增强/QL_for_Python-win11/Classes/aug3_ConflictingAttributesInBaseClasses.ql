/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute,
 *              which may cause unexpected behavior due to attribute overriding conflicts.
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
predicate is_empty_function(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Checks if a function contains a super() call for its own name.
 * This indicates the method properly handles inheritance by calling
 * the parent class's implementation.
 */
predicate has_super_call(FunctionObject func) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection.
 * Currently only includes 'process_request' due to special handling
 * in Python's socketserver module (per documentation).
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"  // Recommended in Python docs for async mixins
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