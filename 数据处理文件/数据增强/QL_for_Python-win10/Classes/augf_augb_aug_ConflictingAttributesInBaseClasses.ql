/**
 * @name Conflicting attributes in base classes
 * @description Identifies classes inheriting from multiple base classes that define the same attribute, 
 *              which may cause unexpected behavior due to attribute resolution ambiguity.
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
 * Determines if a Python function contains only trivial implementation elements.
 * A function is considered trivial if its body consists solely of pass statements 
 * or contains only a docstring.
 */
predicate has_trivial_implementation(PyFunctionObject function) {
  // Check that all statements in the function body are either pass statements
  // or expressions that represent the function's docstring
  not exists(Stmt stmt | stmt.getScope() = function.getFunction() |
    not stmt instanceof Pass and 
    not stmt.(ExprStmt).getValue() = function.getFunction().getDocString()
  )
}

/**
 * Determines if a function utilizes super() for proper method resolution order.
 * This predicate checks if the function contains calls to super() to invoke
 * the parent class's method with the same name.
 */
predicate uses_super_resolution(FunctionObject function) {
  // Look for super() method calls within the function implementation
  exists(Call superCall, Call methodCall, Attribute attr, GlobalVariable superVar |
    methodCall.getScope() = function.getFunction() and
    methodCall.getFunc() = attr and
    attr.getObject() = superCall and
    attr.getName() = function.getName() and
    superCall.getFunc() = superVar.getAnAccess() and
    superVar.getId() = "super"
  )
}

/**
 * Defines attributes that should be excluded from conflict analysis.
 * These attributes have known patterns where conflicts are intentional
 * or handled by the Python runtime in a specific way.
 */
predicate is_attribute_exempted(string attributeName) {
  /*
   * Special exemption for process_request based on Python's socketserver documentation:
   * https://docs.python.org/3/library/socketserver.html#asynchronous-mixins
   * This attribute is commonly overridden in multiple inheritance scenarios
   * and is designed to be handled by the Python runtime.
   */
  attributeName = "process_request"
}

from
  ClassObject derivedClass, 
  ClassObject baseClass1, 
  ClassObject baseClass2, 
  string attributeName, 
  int baseClass1Index, 
  int baseClass2Index, 
  Object attributeInBaseClass1, 
  Object attributeInBaseClass2
where
  // 1. Establish inheritance hierarchy with distinct base classes
  derivedClass.getBaseType(baseClass1Index) = baseClass1 and
  derivedClass.getBaseType(baseClass2Index) = baseClass2 and
  baseClass1Index < baseClass2Index and
  
  // 2. Identify conflicting attribute definitions in both base classes
  attributeInBaseClass1 = baseClass1.lookupAttribute(attributeName) and
  attributeInBaseClass2 = baseClass2.lookupAttribute(attributeName) and
  attributeInBaseClass1 != attributeInBaseClass2 and
  
  // 3. Apply filtering conditions to reduce false positives
  (
    not attributeName.matches("\\_\\_%\\_\\_") and
    not is_attribute_exempted(attributeName) and
    not derivedClass.declaresAttribute(attributeName)
  ) and
  
  // 4. Exclude cases where proper method resolution is implemented
  (
    not uses_super_resolution(attributeInBaseClass1) and
    not has_trivial_implementation(attributeInBaseClass2)
  ) and
  
  // 5. Ensure no override relationship exists between the attributes
  (
    not attributeInBaseClass1.overrides(attributeInBaseClass2) and
    not attributeInBaseClass2.overrides(attributeInBaseClass1)
  )
select derivedClass, 
  "Base classes have conflicting values for attribute '" + attributeName + "': $@ and $@.", 
  attributeInBaseClass1, attributeInBaseClass1.toString(), 
  attributeInBaseClass2, attributeInBaseClass2.toString()