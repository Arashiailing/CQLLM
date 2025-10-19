/**
 * @name Conflicting attributes in base classes
 * @description Finds classes inheriting multiple base classes defining the same attribute, potentially causing unexpected behavior due to attribute resolution order.
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
 * Holds if a function contains only pass statements and/or a docstring.
 */
predicate does_nothing(PyFunctionObject funcObj) {
  not exists(Stmt statement | statement.getScope() = funcObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Holds if a function contains a super() call to invoke parent class methods.
 */
predicate calls_super(FunctionObject funcObj) {
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
 * Holds if an attribute name is exempt from conflict detection due to special cases.
 */
predicate allowed(string attributeName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, ClassObject firstBaseClass, ClassObject secondBaseClass, 
  string attrName, int firstBaseIndex, int secondBaseIndex, 
  Object firstBaseAttr, Object secondBaseAttr
where
  // Inheritance relationship with ordered base classes
  derivedClass.getBaseType(firstBaseIndex) = firstBaseClass and
  derivedClass.getBaseType(secondBaseIndex) = secondBaseClass and
  firstBaseIndex < secondBaseIndex and
  
  // Conflicting attributes exist in base classes
  firstBaseAttr = firstBaseClass.lookupAttribute(attrName) and
  secondBaseAttr = secondBaseClass.lookupAttribute(attrName) and
  firstBaseAttr != secondBaseAttr and
  
  // Exclusion filters for special cases
  (
    // Skip special methods (dunder methods)
    not attrName.matches("\\_\\_%\\_\\_") and
    
    // Exclude safe overrides using super()
    not calls_super(firstBaseAttr) and
    
    // Ignore empty implementations in second base
    not does_nothing(secondBaseAttr) and
    
    // Skip exempted attribute names
    not allowed(attrName) and
    
    // Ensure no override relationship between attributes
    not firstBaseAttr.overrides(secondBaseAttr) and
    not secondBaseAttr.overrides(firstBaseAttr) and
    
    // Verify derived class doesn't declare the attribute
    not derivedClass.declaresAttribute(attrName)
  )
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  firstBaseAttr, firstBaseAttr.toString(), 
  secondBaseAttr, secondBaseAttr.toString()