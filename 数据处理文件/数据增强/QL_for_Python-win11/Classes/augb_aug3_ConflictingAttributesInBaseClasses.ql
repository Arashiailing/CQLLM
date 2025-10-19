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
  ClassObject childClass, 
  ClassObject parentClass1, 
  ClassObject parentClass2, 
  string conflictingAttrName, 
  int parentIndex1, 
  int parentIndex2, 
  Object attrInParent1, 
  Object attrInParent2
where
  // Establish inheritance relationships with distinct base classes
  childClass.getBaseType(parentIndex1) = parentClass1 and
  childClass.getBaseType(parentIndex2) = parentClass2 and
  parentIndex1 < parentIndex2 and
  
  // Locate conflicting attributes in different base classes
  attrInParent1 = parentClass1.lookupAttribute(conflictingAttrName) and
  attrInParent2 = parentClass2.lookupAttribute(conflictingAttrName) and
  attrInParent1 != attrInParent2 and
  
  // Filter out special method names and exempt attributes
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttrName) and
  
  // Exclude cases where inheritance is properly handled
  (
    not has_super_call(attrInParent1) and
    not is_empty_function(attrInParent2) and
    not attrInParent1.overrides(attrInParent2) and
    not attrInParent2.overrides(attrInParent1)
  ) and
  
  // Ensure the derived class doesn't resolve the conflict
  not childClass.declaresAttribute(conflictingAttrName)
select 
  childClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  attrInParent1, attrInParent1.toString(), 
  attrInParent2, attrInParent2.toString()