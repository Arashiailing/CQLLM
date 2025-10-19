/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes where the same attribute is defined in more than one base. Such conflicts may cause unexpected behavior due to attribute resolution ambiguity.
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

/** Determines whether a function has an empty implementation (containing only pass statements or docstrings) */
predicate is_empty_implementation(PyFunctionObject functionObj) {
  // Verify function body contains only pass statements or docstrings
  not exists(Stmt stmt | stmt.getScope() = functionObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = functionObj.getFunction().getDocString()
  )
}

/** Checks whether a function explicitly calls super() for method resolution */
predicate invokes_super(FunctionObject functionObj) {
  // Identify super() calls within function body
  exists(Call superInvocation, Call methodInvocation, Attribute attribute, GlobalVariable superGlobal |
    methodInvocation.getScope() = functionObj.getFunction() and
    methodInvocation.getFunc() = attribute and
    attribute.getObject() = superInvocation and
    attribute.getName() = functionObj.getName() and
    superInvocation.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/** Specifies attributes that are exempt from conflict detection */
predicate is_exempt_attribute(string attributeName) {
  /*
   * Exemption for process_request as documented in Python's socketserver module:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject childClass, 
  ClassObject firstBase, 
  ClassObject secondBase, 
  string attributeName, 
  int index1, 
  int index2, 
  Object firstBaseAttribute, 
  Object secondBaseAttribute
where
  // Establish inheritance relationships with distinct base classes
  childClass.getBaseType(index1) = firstBase and
  childClass.getBaseType(index2) = secondBase and
  index1 < index2 and
  
  // Locate conflicting attributes in base classes
  firstBaseAttribute = firstBase.lookupAttribute(attributeName) and
  secondBaseAttribute = secondBase.lookupAttribute(attributeName) and
  firstBaseAttribute != secondBaseAttribute and
  
  // Exclude special dunder methods from analysis
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  // Skip conflicts where first base properly handles method resolution
  not invokes_super(firstBaseAttribute) and
  
  // Ignore trivial implementations in second base class
  not is_empty_implementation(secondBaseAttribute) and
  
  // Exclude known exempt attributes
  not is_exempt_attribute(attributeName) and
  
  // Verify no override relationship between conflicting attributes
  not firstBaseAttribute.overrides(secondBaseAttribute) and
  not secondBaseAttribute.overrides(firstBaseAttribute) and
  
  // Ensure derived class doesn't declare the conflicting attribute
  not childClass.declaresAttribute(attributeName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  firstBaseAttribute, firstBaseAttribute.toString(), 
  secondBaseAttribute, secondBaseAttribute.toString()