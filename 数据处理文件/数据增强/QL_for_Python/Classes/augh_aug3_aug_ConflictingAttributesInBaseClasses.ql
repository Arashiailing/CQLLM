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
  // Verify that the function body contains no statements other than pass or docstring expressions
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
  // Look for a pattern like super().method_name() within the function body
  exists(Call superInvocation, Call methodInvocation, Attribute attrRef, GlobalVariable superVar |
    methodInvocation.getScope() = func.getFunction() and
    methodInvocation.getFunc() = attrRef and
    attrRef.getObject() = superInvocation and
    attrRef.getName() = func.getName() and
    superInvocation.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
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
  ClassObject parentClassA, 
  ClassObject parentClassB, 
  string conflictingAttrName, 
  int inheritancePosA, 
  int inheritancePosB, 
  Object attrInParentA, 
  Object attrInParentB
where
  // Establish inheritance relationships between child class and its parent classes
  childClass.getBaseType(inheritancePosA) = parentClassA and
  childClass.getBaseType(inheritancePosB) = parentClassB and
  // Ensure parent classes are distinct and ordered by inheritance position
  inheritancePosA < inheritancePosB and
  
  // Locate conflicting attributes in different parent classes
  attrInParentA = parentClassA.lookupAttribute(conflictingAttrName) and
  attrInParentB = parentClassB.lookupAttribute(conflictingAttrName) and
  attrInParentA != attrInParentB and
  
  // Filter out non-problematic conflicts
  not conflictingAttrName.matches("\\_\\_%\\_\\_") and          // Exclude special methods
  not is_exempt_attribute(conflictingAttrName) and             // Exclude known exempt attributes
  not childClass.declaresAttribute(conflictingAttrName) and    // Ensure child class doesn't override
  not attrInParentA.overrides(attrInParentB) and              // No override relationship between attributes
  not attrInParentB.overrides(attrInParentA) and
  not invokes_super(attrInParentA) and                        // Skip if first parent handles resolution
  not is_empty_implementation(attrInParentB)                  // Ignore trivial implementations in second parent
select childClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttrName + "': $@ and $@.", 
  attrInParentA, attrInParentA.toString(), 
  attrInParentB, attrInParentB.toString()