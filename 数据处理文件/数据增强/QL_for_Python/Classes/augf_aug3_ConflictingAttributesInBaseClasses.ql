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
  ClassObject subClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttrName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object firstBaseAttr, 
  Object secondBaseAttr
where
  // Establish inheritance relationships with distinct base classes
  subClass.getBaseType(firstBaseIndex) = firstBaseClass and
  subClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Locate conflicting attributes in different base classes
  firstBaseAttr = firstBaseClass.lookupAttribute(conflictingAttrName) and
  secondBaseAttr = secondBaseClass.lookupAttribute(conflictingAttrName) and
  firstBaseAttr != secondBaseAttr and
  
  // Filter out special method names and exempt attributes
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttrName) and
  
  // Exclude cases where inheritance is properly handled
  not has_super_call(firstBaseAttr) and
  not is_empty_function(secondBaseAttr) and
  not firstBaseAttr.overrides(secondBaseAttr) and
  not secondBaseAttr.overrides(firstBaseAttr) and
  
  // Ensure the derived class doesn't resolve the conflict
  not subClass.declaresAttribute(conflictingAttrName)
select 
  subClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  firstBaseAttr, firstBaseAttr.toString(), 
  secondBaseAttr, secondBaseAttr.toString()