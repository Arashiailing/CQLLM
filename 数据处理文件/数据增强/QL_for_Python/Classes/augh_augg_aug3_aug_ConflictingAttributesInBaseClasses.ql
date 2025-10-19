/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes where identical attributes are defined in more than one base. This creates ambiguity in attribute resolution that may lead to unexpected runtime behavior.
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
 * A function qualifies as empty when its body contains only pass statements or docstrings.
 */
predicate is_empty_implementation(PyFunctionObject function) {
  // Ensure no meaningful statements exist in function body
  not exists(Stmt statement | statement.getScope() = function.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly uses super() for method resolution order.
 * This indicates proper handling of multiple inheritance scenarios by calling parent implementations.
 */
predicate invokes_super(FunctionObject function) {
  // Detect super().method_name() pattern in function body
  exists(Call superInvocation, Call methodInvocation, Attribute attribute, GlobalVariable superGlobal |
    methodInvocation.getScope() = function.getFunction() and
    methodInvocation.getFunc() = attribute and
    attribute.getObject() = superInvocation and
    attribute.getName() = function.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Identifies attribute names excluded from conflict detection.
 * These attributes follow established patterns in multiple inheritance where conflicts are intentional and properly managed.
 */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for process_request as documented in Python's socketserver module:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   * This attribute is intentionally overridden in multiple inheritance patterns
   * and does not represent a problematic conflict.
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int order1, 
  int order2, 
  Object attribute1, 
  Object attribute2
where
  // Establish inheritance relationships with ordering
  derivedClass.getBaseType(order1) = baseClass1 and
  derivedClass.getBaseType(order2) = baseClass2 and
  order1 < order2 and  // Ensure distinct base classes
  
  // Identify conflicting attributes in different base classes
  attribute1 = baseClass1.lookupAttribute(attributeName) and
  attribute2 = baseClass2.lookupAttribute(attributeName) and
  attribute1 != attribute2 and
  
  // Filter non-problematic conflicts
  (
    // Exclude special methods and exempt attributes
    not attributeName.matches("\\_\\_%\\_\\_") and
    not is_exempt_attribute(attributeName) and
    
    // Verify derived class doesn't override the attribute
    not derivedClass.declaresAttribute(attributeName) and
    
    // Ensure no override relationship between attributes
    not attribute1.overrides(attribute2) and
    not attribute2.overrides(attribute1) and
    
    // Skip if first base handles resolution via super()
    not invokes_super(attribute1) and
    
    // Ignore trivial implementations in second base
    not is_empty_implementation(attribute2)
  )
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attribute1, attribute1.toString(), 
  attribute2, attribute2.toString()