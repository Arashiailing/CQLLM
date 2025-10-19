/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting multiple base classes with same attribute definitions, potentially causing unexpected attribute overriding behavior.
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
 * Determines if a function contains only pass statements and a docstring.
 */
predicate is_empty_function(PyFunctionObject fnObj) {
  not exists(Stmt stmt | stmt.getScope() = fnObj.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = fnObj.getFunction().getDocString()
  )
}

/**
 * Checks if a function invokes a parent method via super() call.
 */
predicate has_super_call(FunctionObject fnObj) {
  exists(Call superInvoke, Call methodInvoke, Attribute attribute, GlobalVariable superGlobal |
    methodInvoke.getScope() = fnObj.getFunction() and
    methodInvoke.getFunc() = attribute and
    attribute.getObject() = superInvoke and
    attribute.getName() = fnObj.getName() and
    superInvoke.getFunc() = superGlobal.getAnAccess() and
    superGlobal.getId() = "super"
  )
}

/**
 * Identifies attribute names excluded from conflict detection.
 */
predicate is_exempt_attribute(string attrName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, ClassObject parentClass1, ClassObject parentClass2, 
  string attrName, int idx1, int idx2, 
  Object attr1, Object attr2
where
  // Establish inheritance hierarchy with ordered base classes
  derivedClass.getBaseType(idx1) = parentClass1 and
  derivedClass.getBaseType(idx2) = parentClass2 and
  idx1 < idx2 and
  
  // Identify conflicting attributes in base classes
  attr1 = parentClass1.lookupAttribute(attrName) and
  attr2 = parentClass2.lookupAttribute(attrName) and
  attr1 != attr2 and
  
  // Exclude special methods (dunder methods)
  not attrName.matches("\\_\\_%\\_\\_") and
  
  // Filter safe overriding scenarios
  not has_super_call(attr1) and
  
  // Ignore trivial implementations in second base class
  not is_empty_function(attr2) and
  
  // Skip exempted attribute names
  not is_exempt_attribute(attrName) and
  
  // Verify no override relationship exists
  not attr1.overrides(attr2) and
  not attr2.overrides(attr1) and
  
  // Ensure child class doesn't explicitly declare the attribute
  not derivedClass.declaresAttribute(attrName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  attr1, attr1.toString(), 
  attr2, attr2.toString()