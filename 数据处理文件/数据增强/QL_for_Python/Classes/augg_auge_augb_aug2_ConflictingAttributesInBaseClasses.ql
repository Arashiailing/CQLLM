/**
 * @name Conflicting attributes in base classes
 * @description Detects classes that inherit from multiple base classes which define the same attribute, leading to potential issues from attribute overriding.
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
 * Checks whether a Python function solely consists of pass statements and docstrings.
 * Functions meeting this criterion are regarded as having no substantive implementation.
 */
predicate is_no_op_function(PyFunctionObject func) {
  not exists(Stmt stmt | stmt.getScope() = func.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = func.getFunction().getDocString()
  )
}

/**
 * Verifies if a function makes explicit use of super() to call methods from parent classes.
 * Such usage signifies deliberate method chaining within inheritance structures.
 */
predicate invokes_super_method(FunctionObject func) {
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = func.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = func.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Specifies attribute names that are excluded from conflict detection because of special handling patterns.
 * These exclusions adhere to documented conventions or library guidelines.
 */
predicate is_exempted_attribute(string attrName) {
  /*
   * Exemption for standard library recommendation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  attrName = "process_request"
}

from
  ClassObject derivedClass, ClassObject parentClass1, ClassObject parentClass2, 
  string attributeName, int index1, int index2, 
  Object attributeInParent1, Object attributeInParent2
where
  /* Verify distinct base classes with ordered inheritance positions */
  derivedClass.getBaseType(index1) = parentClass1 and
  derivedClass.getBaseType(index2) = parentClass2 and
  index1 < index2 and
  
  /* Find attributes with identical names in both base classes */
  attributeInParent1 = parentClass1.lookupAttribute(attributeName) and
  attributeInParent2 = parentClass2.lookupAttribute(attributeName) and
  attributeInParent1 != attributeInParent2 and
  
  /* Exclude special methods (dunder methods) which are designed for overriding */
  not attributeName.matches("\\_\\_%\\_\\_") and
  
  /* Skip cases where the first base class properly uses super() (safe overriding) */
  not invokes_super_method(attributeInParent1) and
  
  /* Ignore empty functions in the second base class (no real conflict introduced) */
  not is_no_op_function(attributeInParent2) and
  
  /* Exclude exempted attributes with special handling patterns */
  not is_exempted_attribute(attributeName) and
  
  /* Ensure no override relationship exists between attributes */
  not attributeInParent1.overrides(attributeInParent2) and
  not attributeInParent2.overrides(attributeInParent1) and
  
  /* Verify the child class doesn't explicitly declare the attribute */
  not derivedClass.declaresAttribute(attributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInParent1, attributeInParent1.toString(), 
  attributeInParent2, attributeInParent2.toString()