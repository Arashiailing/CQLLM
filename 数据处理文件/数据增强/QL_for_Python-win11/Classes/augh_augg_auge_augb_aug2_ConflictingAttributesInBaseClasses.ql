/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes that define the same attribute, potentially causing attribute overriding issues.
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
 * Determines if a Python function contains only pass statements and docstrings.
 * Such functions are considered to have no meaningful implementation.
 */
predicate is_no_op_function(PyFunctionObject func) {
  not exists(Stmt statement | statement.getScope() = func.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly uses super() to invoke parent class methods.
 * This indicates intentional method chaining in inheritance hierarchies.
 */
predicate invokes_super_method(FunctionObject func) {
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
 * Defines attribute names excluded from conflict detection due to special handling patterns.
 * These exclusions follow documented conventions or library specifications.
 */
predicate is_exempted_attribute(string attrName) {
  /*
   * Exemption per standard library guidance:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, ClassObject parentClass1, ClassObject parentClass2, 
  string attributeName, int index1, int index2, 
  Object attributeInParent1, Object attributeInParent2
where
  /* Ensure distinct base classes with inheritance order */
  derivedClass.getBaseType(index1) = parentClass1 and
  derivedClass.getBaseType(index2) = parentClass2 and
  index1 < index2 and
  
  /* Identify matching attributes in both base classes */
  attributeInParent1 = parentClass1.lookupAttribute(attributeName) and
  attributeInParent2 = parentClass2.lookupAttribute(attributeName) and
  attributeInParent1 != attributeInParent2 and
  
  /* Exclude special methods designed for overriding */
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  /* Skip cases where first base class uses super() safely */
  not invokes_super_method(attributeInParent1) and
  
  /* Ignore empty implementations in second base class */
  not is_no_op_function(attributeInParent2) and
  
  /* Exclude attributes with special handling patterns */
  not is_exempted_attribute(attributeName) and
  
  /* Verify no override relationship exists */
  not attributeInParent1.overrides(attributeInParent2) and
  not attributeInParent2.overrides(attributeInParent1) and
  
  /* Confirm child class doesn't explicitly declare attribute */
  not derivedClass.declaresAttribute(attributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInParent1, attributeInParent1.toString(), 
  attributeInParent2, attributeInParent2.toString()