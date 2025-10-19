/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes where identical attributes are defined in more than one parent. Such attribute collisions can cause unpredictable behavior due to ambiguous resolution order.
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
 * Determines if a Python function implementation is functionally empty.
 * A function qualifies as empty when its body exclusively contains pass statements or docstring expressions.
 */
predicate is_empty_implementation(PyFunctionObject func) {
  // Validate that function body contains only pass statements or docstring expressions
  not exists(Stmt bodyStmt | bodyStmt.getScope() = func.getFunction() |
    not bodyStmt instanceof Pass and 
    not bodyStmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Identifies functions that explicitly utilize super() for method resolution.
 * This pattern indicates intentional handling of multiple inheritance scenarios
 * through proper parent class method invocation.
 */
predicate invokes_super(FunctionObject func) {
  // Detect super() method invocation pattern within function body
  exists(Call superCall, Call methodCall, Attribute attrRef, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attrRef and
    attrRef.getObject() = superCall and
    attrRef.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Defines attribute names excluded from conflict detection.
 * These attributes follow established multiple inheritance patterns
 * where conflicts are intentionally managed and non-problematic.
 */
predicate is_exempt_attribute(string attrName) {
  /*
   * Exemption for process_request per Python's socketserver documentation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   * This attribute follows expected override patterns in multiple inheritance
   * and does not indicate a problematic conflict scenario.
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject baseClassA, 
  ClassObject baseClassB, 
  string attributeName, 
  int inheritanceOrderA, 
  int inheritanceOrderB, 
  Object attributeInA, 
  Object attributeInB
where
  // Establish inheritance hierarchy with distinct parent classes
  derivedClass.getBaseType(inheritanceOrderA) = baseClassA and
  derivedClass.getBaseType(inheritanceOrderB) = baseClassB and
  inheritanceOrderA < inheritanceOrderB and
  
  // Detect attribute conflicts between parent classes
  attributeInA = baseClassA.lookupAttribute(attributeName) and
  attributeInB = baseClassB.lookupAttribute(attributeName) and
  attributeInA != attributeInB and
  
  // Exclude non-problematic conflict scenarios
  not attributeName.matches("\\_\\_%\\_\\_") and                 // Filter out special methods
  not is_exempt_attribute(attributeName) and                      // Skip exempted attributes
  not derivedClass.declaresAttribute(attributeName) and           // Child doesn't override
  not attributeInA.overrides(attributeInB) and                    // No override relationship
  not attributeInB.overrides(attributeInA) and
  not invokes_super(attributeInA) and                             // First parent handles resolution
  not is_empty_implementation(attributeInB)                       // Second parent has non-trivial implementation
select derivedClass, 
  "Base classes contain conflicting definitions for attribute '" + attributeName + "': $@ and $@.", 
  attributeInA, attributeInA.toString(), 
  attributeInB, attributeInB.toString()