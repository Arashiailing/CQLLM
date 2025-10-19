/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute, which may lead to unexpected behavior due to attribute overriding.
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
 * Determines if a Python function performs no operations beyond pass statements and docstrings.
 * Such functions are considered empty or no-op implementations.
 */
predicate is_no_op_function(PyFunctionObject funcObj) {
  not exists(Stmt statement | statement.getScope() = funcObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly calls super() to invoke parent class methods.
 * This indicates intentional method chaining behavior in inheritance.
 */
predicate invokes_super_method(FunctionObject funcObj) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = funcObj.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = funcObj.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Identifies attribute names that are exempt from conflict detection due to special cases.
 * These exemptions follow documented patterns or library recommendations.
 */
predicate is_exempted_attribute(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, ClassObject firstBaseClass, ClassObject secondBaseClass, 
  string conflictingAttributeName, int firstBaseIndex, int secondBaseIndex, 
  Object attributeInFirstBase, Object attributeInSecondBase
where
  // Ensure two distinct base classes with ordered inheritance positions
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Locate attributes with the same name in both base classes
  attributeInFirstBase = firstBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeInSecondBase = secondBaseClass.lookupAttribute(conflictingAttributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Filter out special methods (dunder methods) which are expected to be overridden
  not conflictingAttributeName.matches("\\_\\_%\\_\\_") and
  
  // Exclude cases where the first base class properly calls super() (safe overriding)
  not invokes_super_method(attributeInFirstBase) and
  
  // Ignore empty functions in the second base class as they don't introduce real conflicts
  not is_no_op_function(attributeInSecondBase) and
  
  // Skip exempted attribute names that have special handling patterns
  not is_exempted_attribute(conflictingAttributeName) and
  
  // Ensure no override relationship exists between attributes to avoid false positives
  not attributeInFirstBase.overrides(attributeInSecondBase) and
  not attributeInSecondBase.overrides(attributeInFirstBase) and
  
  // Verify the derived class doesn't explicitly declare the attribute
  // If it did, it would resolve the conflict intentionally
  not derivedClass.declaresAttribute(conflictingAttributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + conflictingAttributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()