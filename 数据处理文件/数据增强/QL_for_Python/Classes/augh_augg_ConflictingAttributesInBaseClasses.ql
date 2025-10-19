/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes that inherit multiple base classes defining the same attribute,
 *              potentially causing unexpected behavior due to attribute overriding.
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

// Checks if a function consists solely of pass statements or contains only a docstring
predicate isTrivialFunction(PyFunctionObject f) {
  // Verify absence of any non-pass statements or non-docstring expressions
  not exists(Stmt s | s.getScope() = f.getFunction() |
    not s instanceof Pass and not s.(ExprStmt).getValue() = f.getFunction().getDocString()
  )
}

/* Functions that utilize super() calls are considered safe as they explicitly invoke overridden methods */
// Detects functions that make explicit calls to parent methods using super()
predicate usesSuperInvocation(FunctionObject f) {
  // Identify super() method invocations within the function body
  exists(Call sup, Call meth, Attribute attr, GlobalVariable v |
    meth.getScope() = f.getFunction() and
    meth.getFunc() = attr and
    attr.getObject() = sup and
    attr.getName() = f.getName() and
    sup.getFunc() = v.getAnAccess() and
    v.getId() = "super"
  )
}

/** Determines if an attribute name should be exempt from conflict detection */
predicate isExemptedAttributeName(string name) {
  /*
   * Exemption for library-recommended attribute names:
   * Reference: https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   */
  name = "process_request"
}

from
  ClassObject childClass, ClassObject parentClass1, ClassObject parentClass2, 
  string attrName, int parentIndex1, int parentIndex2, Object firstAttr, Object secondAttr
where
  // Establish inheritance relationship with distinct base classes in order
  childClass.getBaseType(parentIndex1) = parentClass1 and
  childClass.getBaseType(parentIndex2) = parentClass2 and
  parentIndex1 < parentIndex2 and
  
  // Identify attributes with same name but different implementations
  firstAttr = parentClass1.lookupAttribute(attrName) and
  secondAttr = parentClass2.lookupAttribute(attrName) and
  firstAttr != secondAttr and
  
  // Filter out special methods and exempted attribute names
  not attrName.matches("\\_\\_%\\_\\_") and
  not isExemptedAttributeName(attrName) and
  
  // Exclude cases where conflict is resolved through super() calls or trivial methods
  not usesSuperInvocation(firstAttr) and
  not isTrivialFunction(secondAttr) and
  
  // Ensure no override relationship exists between the attributes
  not firstAttr.overrides(secondAttr) and
  not secondAttr.overrides(firstAttr) and
  
  // Verify the child class does not override the conflicting attribute
  not childClass.declaresAttribute(attrName)
select childClass, 
  "Base classes have conflicting values for attribute '" + attrName + "': $@ and $@.", 
  firstAttr, firstAttr.toString(), secondAttr, secondAttr.toString()