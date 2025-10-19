/**
 * @name Base class attribute conflicts
 * @description Detects derived classes inheriting multiple base classes with identically named attributes, potentially causing unintended behavior due to attribute overriding.
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
 * Determines if a Python function consists solely of pass statements and docstrings,
 * indicating an empty implementation without substantial logic.
 */
predicate is_no_op_function(PyFunctionObject functionObj) {
  not exists(Stmt statement | 
    statement.getScope() = functionObj.getFunction() and
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Checks whether a function explicitly uses super() to invoke parent class methods,
 * indicating intentional method chaining in inheritance hierarchies.
 */
predicate invokes_super_method(FunctionObject functionObj) {
  exists(Call superInvocation, Call methodInvocation, Attribute attributeRef, GlobalVariable superGlobal |
    methodInvocation.getScope() = functionObj.getFunction() and
    methodInvocation.getFunc() = attributeRef and
    attributeRef.getObject() = superInvocation and
    attributeRef.getName() = functionObj.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Identifies attribute names exempt from conflict detection due to special handling patterns,
 * following documented conventions or library recommendations.
 */
predicate is_exempted_attribute(string attributeName) {
  /*
   * Exemption based on standard library guidance:
   * Refer to https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, ClassObject firstBase, ClassObject secondBase, 
  string attributeName, int firstBaseIndex, int secondBaseIndex, 
  Object attributeInFirstBase, Object attributeInSecondBase
where
  // Ensure distinct base classes with inheritance order
  derivedClass.getBaseType(firstBaseIndex) = firstBase and
  derivedClass.getBaseType(secondBaseIndex) = secondBase and
  firstBaseIndex < secondBaseIndex and
  
  // Identify attributes with matching names in both base classes
  attributeInFirstBase = firstBase.lookupAttribute(attributeName) and
  attributeInSecondBase = secondBase.lookupAttribute(attributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Exclude special methods (dunder methods) intended for overriding
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  // Skip cases where the first base class properly uses super() (indicating safe overriding)
  not invokes_super_method(attributeInFirstBase) and
  
  // Ignore empty functions in the second base class (which don't introduce real conflicts)
  not is_no_op_function(attributeInSecondBase) and
  
  // Exclude attributes with special handling patterns (exempted)
  not is_exempted_attribute(attributeName) and
  
  // Ensure no override relationship exists between the attributes
  not attributeInFirstBase.overrides(attributeInSecondBase) and
  not attributeInSecondBase.overrides(attributeInFirstBase) and
  
  // Verify the derived class does not explicitly declare the attribute
  // (explicit declaration would intentionally resolve the conflict)
  not derivedClass.declaresAttribute(attributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()