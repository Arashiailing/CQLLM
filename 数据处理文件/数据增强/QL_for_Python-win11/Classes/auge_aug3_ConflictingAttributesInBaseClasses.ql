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
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttributeName, 
  int firstBaseIndex, 
  int secondBaseIndex, 
  Object attributeInFirstBase, 
  Object attributeInSecondBase
where
  // Establish inheritance relationships with distinct base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Locate conflicting attributes in different base classes
  attributeInFirstBase = firstBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeInSecondBase = secondBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Filter out special method names and exempt attributes
  not conflictingAttributeName.matches("\\_\\_%\\_\\_") and
  not is_exempt_attribute(conflictingAttributeName) and
  
  // Exclude cases where inheritance is properly handled
  not has_super_call(attributeInFirstBase) and
  not is_empty_function(attributeInSecondBase) and
  not attributeInFirstBase.overrides(attributeInSecondBase) and
  not attributeInSecondBase.overrides(attributeInFirstBase) and
  
  // Ensure the derived class doesn't resolve the conflict
  not derivedClass.declaresAttribute(conflictingAttributeName)
select 
  derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()