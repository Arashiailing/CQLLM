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
 * Check if a function only contains pass statements and a docstring.
 */
predicate is_empty_function(PyFunctionObject funcObj) {
  not exists(Stmt statement | statement.getScope() = funcObj.getFunction() |
    not statement instanceof Pass and 
    not statement.(ExprStmt).getValue() = funcObj.getFunction().getDocString()
  )
}

/**
 * Check if a function calls super() to invoke a parent class method.
 */
predicate has_super_call(FunctionObject funcObj) {
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
 * Identify attribute names exempt from conflict detection.
 */
predicate is_exempt_attribute(string attrName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, ClassObject firstBase, ClassObject secondBase, 
  string attrName, int firstIndex, int secondIndex, 
  Object firstAttr, Object secondAttr
where
  // Ensure distinct base classes with ordered inheritance
  derivedClass.getBaseType(firstIndex) = firstBase and
  derivedClass.getBaseType(secondIndex) = secondBase and
  firstIndex < secondIndex and
  
  // Locate conflicting attributes in base classes
  firstAttr = firstBase.lookupAttribute(attrName) and
  secondAttr = secondBase.lookupAttribute(attrName) and
  firstAttr != secondAttr and
  
  // Filter special methods (dunder methods)
  not attrName.matches("\\_\\_%\\_\\_") and
  
  // Exclude safe overriding cases
  not has_super_call(firstAttr) and
  
  // Ignore empty implementations in second base
  not is_empty_function(secondAttr) and
  
  // Skip exempted attribute names
  not is_exempt_attribute(attrName) and
  
  // Verify no override relationship exists
  not firstAttr.overrides(secondAttr) and
  not secondAttr.overrides(firstAttr) and
  
  // Ensure child class doesn't explicitly declare the attribute
  not derivedClass.declaresAttribute(attrName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  firstAttr, firstAttr.toString(), 
  secondAttr, secondAttr.toString()