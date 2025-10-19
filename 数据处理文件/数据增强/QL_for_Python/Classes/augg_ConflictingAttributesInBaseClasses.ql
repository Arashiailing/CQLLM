/**
 * @name Conflicting attributes in base classes
 * @description Detects when a class inherits multiple base classes defining the same attribute,
 *              which may lead to unexpected behavior due to attribute overriding.
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

// Determines if a function contains only pass statements or docstrings
predicate isEmptyFunction(PyFunctionObject f) {
  // Check for any non-pass statements or non-docstring expressions
  not exists(Stmt s | s.getScope() = f.getFunction() |
    not s instanceof Pass and not s.(ExprStmt).getValue() = f.getFunction().getDocString()
  )
}

/* Methods using super() calls are safe as they explicitly invoke overridden methods */
// Identifies functions that explicitly call parent methods via super()
predicate invokesSuperCall(FunctionObject f) {
  // Detect super() method calls within function body
  exists(Call sup, Call meth, Attribute attr, GlobalVariable v |
    meth.getScope() = f.getFunction() and
    meth.getFunc() = attr and
    attr.getObject() = sup and
    attr.getName() = f.getName() and
    sup.getFunc() = v.getAnAccess() and
    v.getId() = "super"
  )
}

/** Holds if attribute name is exempt from conflict detection */
predicate isPermittedName(string name) {
  /*
   * Exemption for library-recommended names:
   * See https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  name = "process_request"
}

from
  ClassObject derivedClass, ClassObject baseClass1, ClassObject baseClass2, 
  string attributeName, int baseIndex1, int baseIndex2, Object attr1, Object attr2
where
  // Identify distinct base classes with inheritance order
  derivedClass.getBaseType(baseIndex1) = baseClass1 and
  derivedClass.getBaseType(baseIndex2) = baseClass2 and
  baseIndex1 < baseIndex2 and
  // Find conflicting attributes in different base classes
  attr1 = baseClass1.lookupAttribute(attributeName) and
  attr2 = baseClass2.lookupAttribute(attributeName) and
  attr1 != attr2 and
  // Exclude special methods and permitted names
  not attributeName.matches("\\_\\_%\\_\\_") and
  not isPermittedName(attributeName) and
  // Filter cases where conflict is resolved via super() or empty methods
  not invokesSuperCall(attr1) and
  not isEmptyFunction(attr2) and
  // Ensure no override relationship between attributes
  not attr1.overrides(attr2) and
  not attr2.overrides(attr1) and
  // Verify derived class doesn't override the attribute
  not derivedClass.declaresAttribute(attributeName)
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attr1, attr1.toString(), attr2, attr2.toString()