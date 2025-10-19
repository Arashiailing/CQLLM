/**
 * @name Special method has incorrect signature
 * @description Detects special methods with incorrect parameter counts
 * @kind problem
 * @tags reliability
 *       correctness
 *       quality
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/special-method-wrong-signature
 */

import python
import semmle.python.dataflow.new.internal.DataFlowDispatch as DD

// Identifies unary operator methods
predicate is_unary_op(string methodName) {
  methodName in [
      "__del__", "__repr__", "__neg__", "__pos__", "__abs__", "__invert__", "__complex__",
      "__int__", "__float__", "__long__", "__oct__", "__hex__", "__str__", "__index__", "__enter__",
      "__hash__", "__bool__", "__nonzero__", "__unicode__", "__len__", "__iter__", "__reversed__",
      "__aenter__", "__aiter__", "__anext__", "__await__", "__ceil__", "__floor__", "__trunc__",
      "__length_hint__", "__dir__", "__bytes__"
    ]
}

// Identifies binary operator methods
predicate is_binary_op(string methodName) {
  methodName in [
      "__lt__", "__le__", "__delattr__", "__delete__", "__instancecheck__", "__subclasscheck__",
      "__getitem__", "__delitem__", "__contains__", "__add__", "__sub__", "__mul__", "__eq__",
      "__floordiv__", "__div__", "__truediv__", "__mod__", "__divmod__", "__lshift__", "__rshift__",
      "__and__", "__xor__", "__or__", "__ne__", "__radd__", "__rsub__", "__rmul__", "__rfloordiv__",
      "__rdiv__", "__rtruediv__", "__rmod__", "__rdivmod__", "__rpow__", "__rlshift__", "__gt__",
      "__rrshift__", "__rand__", "__rxor__", "__ror__", "__iadd__", "__isub__", "__imul__",
      "__ifloordiv__", "__idiv__", "__itruediv__", "__ge__", "__imod__", "__ipow__", "__ilshift__",
      "__irshift__", "__iand__", "__ixor__", "__ior__", "__coerce__", "__cmp__", "__rcmp__",
      "__getattr__", "__getattribute__", "__buffer__", "__release_buffer__", "__matmul__",
      "__rmatmul__", "__imatmul__", "__missing__", "__class_getitem__", "__mro_entries__",
      "__format__"
    ]
}

// Identifies ternary operator methods
predicate is_ternary_op(string methodName) {
  methodName in ["__setattr__", "__set__", "__setitem__", "__getslice__", "__delslice__", "__set_name__"]
}

// Identifies quaternary operator methods
predicate is_quad_op(string methodName) { 
  methodName in ["__setslice__", "__exit__", "__aexit__"] 
}

// Calculates expected argument count for special methods
int expected_argument_count(string methodName) {
  is_unary_op(methodName) and result = 1
  or
  is_binary_op(methodName) and result = 2
  or
  is_ternary_op(methodName) and result = 3
  or
  is_quad_op(methodName) and result = 4
}

/**
 * Returns 1 for static methods, 0 otherwise. Adjusts expected parameter counts.
 */
int static_method_adjustment(Function method) {
  if DD::isStaticmethod(method) then result = 1 else result = 0
}

// Detects incorrectly defined special methods
predicate has_incorrect_signature(
  Function method, string errorMsg, boolean showArgCounts, string methodName, boolean hasUnusedDefaults
) {
  exists(int expected, int adjustment |
    expected = expected_argument_count(methodName) - adjustment and 
    adjustment = static_method_adjustment(method)
  |
    if expected > method.getMaxPositionalArguments()
    then 
      errorMsg = "Too few parameters" and 
      showArgCounts = true and 
      hasUnusedDefaults = false
    else if expected < method.getMinPositionalArguments()
    then 
      errorMsg = "Too many parameters" and 
      showArgCounts = true and 
      hasUnusedDefaults = false
    else (
      method.getMinPositionalArguments() < expected and
      not method.hasVarArg() and
      errorMsg = (expected - method.getMinPositionalArguments()) + " default value(s) will never be used" and
      showArgCounts = false and
      hasUnusedDefaults = true
    )
  )
}

// Detects incorrectly defined __pow__ methods
predicate has_incorrect_pow_signature(
  Function method, string errorMsg, boolean showArgCounts, boolean hasUnusedDefaults
) {
  exists(int adjustment | adjustment = static_method_adjustment(method) |
    method.getMaxPositionalArguments() < 2 - adjustment and
    errorMsg = "Too few parameters" and
    showArgCounts = true and
    hasUnusedDefaults = false
    or
    method.getMinPositionalArguments() > 3 - adjustment and
    errorMsg = "Too many parameters" and
    showArgCounts = true and
    hasUnusedDefaults = false
    or
    method.getMinPositionalArguments() < 2 - adjustment and
    errorMsg = (2 - method.getMinPositionalArguments()) + " default value(s) will never be used" and
    showArgCounts = false and
    hasUnusedDefaults = true
    or
    method.getMinPositionalArguments() = 3 - adjustment and
    errorMsg = "Third parameter to __pow__ should have a default value" and
    showArgCounts = false and
    hasUnusedDefaults = false
  )
}

// Detects incorrectly defined __round__ methods
predicate has_incorrect_round_signature(
  Function method, string errorMsg, boolean showArgCounts, boolean hasUnusedDefaults
) {
  exists(int adjustment | adjustment = static_method_adjustment(method) |
    method.getMaxPositionalArguments() < 1 - adjustment and
    errorMsg = "Too few parameters" and
    showArgCounts = true and
    hasUnusedDefaults = false
    or
    method.getMinPositionalArguments() > 2 - adjustment and
    errorMsg = "Too many parameters" and
    showArgCounts = true and
    hasUnusedDefaults = false
    or
    method.getMinPositionalArguments() = 2 - adjustment and
    errorMsg = "Second parameter to __round__ should have a default value" and
    showArgCounts = false and
    hasUnusedDefaults = false
  )
}

// Detects incorrectly defined __get__ methods
predicate has_incorrect_get_signature(
  Function method, string errorMsg, boolean showArgCounts, boolean hasUnusedDefaults
) {
  exists(int adjustment | adjustment = static_method_adjustment(method) |
    method.getMaxPositionalArguments() < 3 - adjustment and
    errorMsg = "Too few parameters" and
    showArgCounts = true and
    hasUnusedDefaults = false
    or
    method.getMinPositionalArguments() > 3 - adjustment and
    errorMsg = "Too many parameters" and
    showArgCounts = true and
    hasUnusedDefaults = false
    or
    method.getMinPositionalArguments() < 2 - adjustment and
    not method.hasVarArg() and
    errorMsg = (2 - method.getMinPositionalArguments()) + " default value(s) will never be used" and
    showArgCounts = false and
    hasUnusedDefaults = true
  )
}

// Returns expected parameter count description
string expected_parameter_description(string methodName) {
  if methodName in ["__pow__", "__get__"]
  then result = "2 or 3"
  else result = expected_argument_count(methodName).toString()
}

// Returns actual parameter count description
string actual_parameter_description(Function method) {
  exists(int paramCount | paramCount = method.getMinPositionalArguments() |
    paramCount = 0 and result = "no parameters"
    or
    paramCount = 1 and result = "1 parameter"
    or
    paramCount > 1 and result = paramCount.toString() + " parameters"
  )
}

/** Identifies placeholder functions that shouldn't be flagged */
predicate is_placeholder_function(Function method) {
  method.getBody().getItem(0) = method.getBody().getLastItem() and
  (
    method.getBody().getLastItem().(ExprStmt).getValue() instanceof StringLiteral
    or
    method.getBody().getLastItem() instanceof Raise
    or
    method.getBody().getLastItem() instanceof Pass
  )
}

from
  Function method, string errorMsg, string paramInfo, boolean showArgCounts, string methodName, 
  Class containingClass, boolean hasUnusedDefaults
where
  containingClass.getAMethod() = method and
  method.getName() = methodName and
  (
    has_incorrect_signature(method, errorMsg, showArgCounts, methodName, hasUnusedDefaults)
    or
    has_incorrect_pow_signature(method, errorMsg, showArgCounts, hasUnusedDefaults) and methodName = "__pow__"
    or
    has_incorrect_get_signature(method, errorMsg, showArgCounts, hasUnusedDefaults) and methodName = "__get__"
    or
    has_incorrect_round_signature(method, errorMsg, showArgCounts, hasUnusedDefaults) and methodName = "__round__"
  ) and
  not is_placeholder_function(method) and
  hasUnusedDefaults = false and
  (
    showArgCounts = false and paramInfo = ""
    or
    showArgCounts = true and 
    paramInfo = ", which has " + actual_parameter_description(method) + 
                ", but should have " + expected_parameter_description(methodName)
  )
select method, errorMsg + " for special method " + methodName + paramInfo + ", in class $@.", 
       containingClass, containingClass.getName()