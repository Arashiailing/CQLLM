/**
 * @name Conflicting attributes in base classes
 * @description Detects classes that inherit from multiple base classes with identically named attributes defined in more than one base class. Such attribute conflicts create resolution ambiguity that may result in unexpected runtime behavior.
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
 * Checks whether a Python function has an empty implementation.
 * A function is considered empty if its body consists solely of pass statements or docstrings.
 */
predicate is_empty_implementation(PyFunctionObject function) {
  not exists(Stmt statement | statement.getScope() = function.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

/**
 * Determines if a function explicitly invokes super() for method resolution.
 * Such usage indicates proper handling of multiple inheritance by calling parent implementations.
 */
predicate invokes_super(FunctionObject function) {
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
 * Identifies attribute names that are exempt from conflict detection.
 * These attributes follow established patterns in multiple inheritance where conflicts are intentional and properly managed.
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"
}

from
  ClassObject childClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string conflictingAttributeName, 
  int firstBaseOrder, 
  int secondBaseOrder, 
  Object firstBaseAttribute, 
  Object secondBaseAttribute
where
  // Inheritance relationships with ordering
  childClass.getBaseType(firstBaseOrder) = firstBaseClass and
  childClass.getBaseType(secondBaseOrder) = secondBaseClass and
  firstBaseOrder < secondBaseOrder and

  // Conflicting attributes in different base classes
  firstBaseAttribute = firstBaseClass.lookupAttribute(conflictingAttributeName) and
  secondBaseAttribute = secondBaseClass.lookupAttribute(conflictingAttributeName) and
  firstBaseAttribute != secondBaseAttribute and

  // Filter out non-problematic conflicts
  (
    // Exclude special methods and exempt attributes
    not conflictingAttributeName.matches("\\_\\_%\\_\\_") and
    not is_exempt_attribute(conflictingAttributeName) and

    // Verify child class does not override the attribute
    not childClass.declaresAttribute(conflictingAttributeName) and

    // Ensure no override relationship between the conflicting attributes
    not firstBaseAttribute.overrides(secondBaseAttribute) and
    not secondBaseAttribute.overrides(firstBaseAttribute) and

    // Skip if the first base's attribute uses super() for resolution
    not invokes_super(firstBaseAttribute) and

    // Ignore trivial implementations in the second base
    not is_empty_implementation(secondBaseAttribute)
  )
select childClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttributeName + "': $@ and $@.", 
  firstBaseAttribute, firstBaseAttribute.toString(), 
  secondBaseAttribute, secondBaseAttribute.toString()