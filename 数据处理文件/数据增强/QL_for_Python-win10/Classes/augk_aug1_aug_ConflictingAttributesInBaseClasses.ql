/**
 * @name Conflicting attributes in base classes
 * @description Detects classes that inherit from multiple base classes with the same attribute defined in more than one base. These conflicts can lead to unexpected behavior due to attribute resolution ambiguity.
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

/** Determines whether a function implementation is effectively empty (contains only pass statements or docstrings) */
predicate is_empty_implementation(PyFunctionObject functionObj) {
  // Verify function body contains only pass statements or docstrings
  not exists(Stmt statement | statement.getScope() = functionObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/** Identifies whether a function explicitly calls super() for method resolution */
predicate invokes_super(FunctionObject functionObj) {
  // Identify super() calls within function body
  exists(Call superInvocation, Call methodInvocation, Attribute attributeRef, GlobalVariable superGlobal |
    methodInvocation.getScope() = functionObj.getFunction() and
    methodInvocation.getFunc() = attributeRef and
    attributeRef.getObject() = superInvocation and
    attributeRef.getName() = functionObj.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/** Excludes process_request attribute from conflict detection as documented in Python's socketserver module:
 * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
 */
predicate is_exempt_attribute(string attributeName) {
  attributeName = "process_request"
}

from
  ClassObject childClass, 
  ClassObject firstBase, 
  ClassObject secondBase, 
  string attributeName, 
  int firstIndex, 
  int secondIndex, 
  Object attributeInFirstBase, 
  Object attributeInSecondBase
where
  // Inheritance relationship conditions
  childClass.getBaseType(firstIndex) = firstBase and
  childClass.getBaseType(secondIndex) = secondBase and
  firstIndex < secondIndex and
  
  // Attribute conflict conditions
  attributeInFirstBase = firstBase.lookupAttribute(attributeName) and
  attributeInSecondBase = secondBase.lookupAttribute(attributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Exclusion conditions
  not attributeName.matches("\\_\\_%\\_\\_") and  // Exclude special dunder methods
  not is_exempt_attribute(attributeName) and    // Exclude known exempt attributes
  
  // Method resolution conditions
  not invokes_super(attributeInFirstBase) and    // Skip conflicts where first base properly handles method resolution
  not is_empty_implementation(attributeInSecondBase) and  // Ignore trivial implementations in second base class
  
  // Override relationship conditions
  not attributeInFirstBase.overrides(attributeInSecondBase) and
  not attributeInSecondBase.overrides(attributeInFirstBase) and
  
  // Derived class conditions
  not childClass.declaresAttribute(attributeName)  // Ensure derived class doesn't declare the conflicting attribute
select childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()