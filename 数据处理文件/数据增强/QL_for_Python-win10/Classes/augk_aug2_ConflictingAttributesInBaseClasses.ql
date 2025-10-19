/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute, 
 *              potentially causing unexpected behavior due to attribute overriding conflicts.
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
 * Identifies Python functions that contain only pass statements and docstrings,
 * indicating no meaningful implementation.
 */
predicate is_empty_function(PyFunctionObject functionObj) {
  not exists(Stmt stmt | stmt.getScope() = functionObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Determines if a function explicitly invokes parent class methods using super(),
 * indicating safe method overriding practice.
 */
predicate uses_super_call(FunctionObject functionObj) {
  exists(Call superInvocation, Call methodCall, Attribute attrRef, GlobalVariable superVar |
    methodCall.getScope() = functionObj.getFunction() and
    methodCall.getFunc() = attrRef and
    attrRef.getObject() = superInvocation and
    attrRef.getName() = functionObj.getName() and
    superInvocation.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Defines attribute names exempt from conflict detection due to special cases
 * or established patterns in Python libraries.
 */
predicate is_exempt_attribute(string attrName) {
  /* 
   * Exemption for socketserver async mixins pattern:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject firstBaseClass, 
  ClassObject secondBaseClass, 
  string attrName, 
  int firstIndex, 
  int secondIndex, 
  Object firstBaseAttr, 
  Object secondBaseAttr
where
  // Inheritance hierarchy validation
  derivedClass.getBaseType(firstIndex) = firstBaseClass and
  derivedClass.getBaseType(secondIndex) = secondBaseClass and
  firstIndex < secondIndex and
  
  // Attribute conflict detection
  firstBaseAttr = firstBaseClass.lookupAttribute(attrName) and
  secondBaseAttr = secondBaseClass.lookupAttribute(attrName) and
  firstBaseAttr != secondBaseAttr and
  
  // Filtering conditions
  not attrName.matches("\\_\\_%\\_\\_") and          // Exclude dunder methods
  not uses_super_call(firstBaseAttr) and             // Require safe override
  not is_empty_function(secondBaseAttr) and          // Skip empty implementations
  not is_exempt_attribute(attrName) and              // Skip exempted attributes
  
  // Override relationship checks
  not firstBaseAttr.overrides(secondBaseAttr) and
  not secondBaseAttr.overrides(firstBaseAttr) and
  
  // Derived class attribute validation
  not derivedClass.declaresAttribute(attrName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  firstBaseAttr, firstBaseAttr.toString(), 
  secondBaseAttr, secondBaseAttr.toString()