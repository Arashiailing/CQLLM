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
 * Identifies attribute names that are exempt from conflict detection.
 * Currently only includes 'process_request' due to special handling
 * in Python's socketserver module (per documentation).
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"  // Recommended in Python docs for async mixins
}

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

from
  ClassObject subClass, 
  ClassObject baseClassA, 
  ClassObject baseClassB, 
  string conflictingAttr, 
  int baseIndexA, 
  int baseIndexB, 
  Object attrInBaseA, 
  Object attrInBaseB
where
  // Establish distinct inheritance relationships with ordered base classes
  subClass.getBaseType(baseIndexA) = baseClassA and
  subClass.getBaseType(baseIndexB) = baseClassB and
  baseIndexA < baseIndexB and
  
  // Identify conflicting attributes in different base classes
  attrInBaseA = baseClassA.lookupAttribute(conflictingAttr) and
  attrInBaseB = baseClassB.lookupAttribute(conflictingAttr) and
  attrInBaseA != attrInBaseB and
  
  // Filter out special methods and exempt attributes
  not conflictingAttr.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttr) and
  
  // Exclude properly handled inheritance cases
  not has_super_call(attrInBaseA) and
  not is_empty_function(attrInBaseB) and
  not attrInBaseA.overrides(attrInBaseB) and
  not attrInBaseB.overrides(attrInBaseA) and
  
  // Ensure conflict isn't resolved in derived class
  not subClass.declaresAttribute(conflictingAttr)
select 
  subClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttr + "': $@ and $@.", 
  attrInBaseA, attrInBaseA.toString(), 
  attrInBaseB, attrInBaseB.toString()