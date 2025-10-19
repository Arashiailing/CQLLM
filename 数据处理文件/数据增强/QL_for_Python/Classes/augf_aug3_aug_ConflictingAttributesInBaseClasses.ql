/**
 * @name Conflicting attributes in base classes
 * @description Detects classes that inherit from multiple base classes where more than one base class defines the same attribute. Such conflicts can lead to unexpected behavior due to attribute resolution ambiguity.
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
 * Determines if a Python function implementation is effectively empty.
 * A function is considered empty if its body contains only pass statements or docstrings.
 */
predicate is_empty_implementation(PyFunctionObject func) {
  // Verify function body contains only pass statements or docstring expressions
  not exists(Stmt statement | statement.getScope() = func.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly invokes super() for method resolution.
 * This indicates that the function is designed to work in a multiple inheritance scenario
 * by properly calling the parent class implementation.
 */
predicate invokes_super(FunctionObject func) {
  // Identify super() method call pattern within function body
  exists(Call superInvocation, Call methodInvocation, Attribute attribute, GlobalVariable superGlobal |
    methodInvocation.getScope() = func.getFunction() and
    methodInvocation.getFunc() = attribute and
    attribute.getObject() = superInvocation and
    attribute.getName() = func.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection.
 * These attributes have known patterns of usage in multiple inheritance scenarios
 * where conflicts are expected and handled appropriately.
 */
predicate is_exempt_attribute(string attrName) {
  /*
   * Exemption for process_request as documented in Python's socketserver module:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   * This attribute is intentionally overridden in multiple inheritance patterns
   * and does not represent a problematic conflict.
   */
  attrName = "process_request"
}

from
  ClassObject childClass, 
  ClassObject parentA, 
  ClassObject parentB, 
  string conflictAttrName, 
  int orderA, 
  int orderB, 
  Object attrInParentA, 
  Object attrInParentB
where
  // Establish inheritance relationships between child class and its parents
  childClass.getBaseType(orderA) = parentA and
  childClass.getBaseType(orderB) = parentB and
  // Ensure distinct parent classes with ordered inheritance positions
  orderA < orderB and
  
  // Identify conflicting attributes in different parent classes
  attrInParentA = parentA.lookupAttribute(conflictAttrName) and
  attrInParentB = parentB.lookupAttribute(conflictAttrName) and
  attrInParentA != attrInParentB and
  
  // Filter out non-problematic conflicts
  not conflictAttrName.matches("\\_\\_%\\_\\_") and             // Exclude special methods
  not is_exempt_attribute(conflictAttrName) and                // Exclude known exempt attributes
  not childClass.declaresAttribute(conflictAttrName) and        // Ensure child doesn't override
  not attrInParentA.overrides(attrInParentB) and               // No override relationship
  not attrInParentB.overrides(attrInParentA) and
  not invokes_super(attrInParentA) and                         // Skip if first parent handles resolution
  not is_empty_implementation(attrInParentB)                    // Ignore trivial implementations in second parent
select childClass, 
  "Base classes have conflicting values for attribute '" + conflictAttrName + "': $@ and $@.", 
  attrInParentA, attrInParentA.toString(), 
  attrInParentB, attrInParentB.toString()