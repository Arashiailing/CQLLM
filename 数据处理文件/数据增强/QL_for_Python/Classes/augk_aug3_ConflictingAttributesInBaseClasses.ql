/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes that inherit from multiple base classes which define 
 *              the same attribute, potentially causing unexpected behavior due to 
 *              attribute overriding conflicts.
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
 * Determines whether a function implementation contains no meaningful code.
 * A function is considered to have no implementation if its body consists solely
 * of pass statements or its docstring expression.
 */
predicate is_empty_function(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Checks if a function properly handles inheritance by calling the parent class's
 * implementation using super() for its own method name.
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
 * Identifies attribute names that should be excluded from conflict detection.
 * Currently only 'process_request' is exempt due to special handling
 * in Python's socketserver module (as documented).
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"  // Recommended in Python docs for async mixins
}

from
  ClassObject childClass, 
  ClassObject parentClass1, 
  ClassObject parentClass2, 
  string conflictingAttr, 
  int parentIndex1, 
  int parentIndex2, 
  Object attrInParent1, 
  Object attrInParent2
where
  // Establish inheritance relationships with distinct parent classes
  childClass.getBaseType(parentIndex1) = parentClass1 and
  childClass.getBaseType(parentIndex2) = parentClass2 and
  parentIndex1 < parentIndex2 and
  
  // Find the same attribute defined in both parent classes
  attrInParent1 = parentClass1.lookupAttribute(conflictingAttr) and
  attrInParent2 = parentClass2.lookupAttribute(conflictingAttr) and
  attrInParent1 != attrInParent2 and
  
  // Exclude special method names (dunder methods) and exempt attributes
  not conflictingAttr.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttr) and
  
  // Filter out cases where inheritance is properly handled
  not has_super_call(attrInParent1) and
  not is_empty_function(attrInParent2) and
  not attrInParent1.overrides(attrInParent2) and
  not attrInParent2.overrides(attrInParent1) and
  
  // Ensure the child class doesn't resolve the conflict by overriding
  not childClass.declaresAttribute(conflictingAttr)
select 
  childClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttr + "': $@ and $@.", 
  attrInParent1, attrInParent1.toString(), 
  attrInParent2, attrInParent2.toString()