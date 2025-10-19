/**
 * @name Conflicting attributes in base classes
 * @description Identifies when a class inherits from multiple base classes that define the same attribute,
 *              potentially leading to unexpected behavior due to attribute overriding conflicts.
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
 * Determines whether a Python function contains only pass statements and docstrings,
 * effectively performing no operations.
 */
predicate does_nothing(PyFunctionObject functionObj) {
  not exists(Stmt stmt | stmt.getScope() = functionObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function explicitly invokes the parent class method using super(),
 * indicating intentional method overriding.
 */
predicate calls_super(FunctionObject functionObj) {
  exists(Call superInvocation, Call methodInvocation, Attribute attribute, GlobalVariable superGlobalVar |
    methodInvocation.getScope() = functionObj.getFunction() and
    methodInvocation.getFunc() = attribute and
    attribute.getObject() = superInvocation and
    attribute.getName() = functionObj.getName() and
    superInvocation.getFunc() = superGlobalVar.getAnAccess() and
    superGlobalVar.getId() = "super"
  )
}

/**
 * Specifies attribute names that should be exempt from conflict detection
 * due to special cases or standard library recommendations.
 */
predicate allowed(string attributeName) {
  /*
   * Exemption based on standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, ClassObject firstBaseClass, ClassObject secondBaseClass, 
  string attributeName, int firstBaseIndex, int secondBaseIndex, 
  Object attributeInFirstBase, Object attributeInSecondBase
where
  // Verify inheritance structure with ordered base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Identify conflicting attributes in both base classes
  attributeInFirstBase = firstBaseClass.lookupAttribute(attributeName) and
  attributeInSecondBase = secondBaseClass.lookupAttribute(attributeName) and
  attributeInFirstBase != attributeInSecondBase and
  
  // Filter conditions for attribute conflicts
  (
    // Exclude special methods (dunder methods)
    not attributeName.matches("\\_\\_%\\_\\_") and
    
    // Exclude cases where super() is called (safe overriding)
    not calls_super(attributeInFirstBase) and
    
    // Ignore empty functions in the second base class
    not does_nothing(attributeInSecondBase) and
    
    // Skip exempted attribute names
    not allowed(attributeName) and
    
    // Ensure no override relationship exists between attributes
    not attributeInFirstBase.overrides(attributeInSecondBase) and
    not attributeInSecondBase.overrides(attributeInFirstBase) and
    
    // Verify derived class doesn't explicitly declare the attribute
    not derivedClass.declaresAttribute(attributeName)
  )
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInFirstBase, attributeInFirstBase.toString(), 
  attributeInSecondBase, attributeInSecondBase.toString()