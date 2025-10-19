/**
 * @name Special method has incorrect signature
 * @description Detects special methods with incorrect parameter signatures
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
predicate is_quad_op(string methodName) { methodName in ["__setslice__", "__exit__", "__aexit__"] }

// Determines expected parameter count for special methods
int expected_arg_count(string methodName) {
  is_unary_op(methodName) and result = 1
  or
  is_binary_op(methodName) and result = 2
  or
  is_ternary_op(methodName) and result = 3
  or
  is_quad_op(methodName) and result = 4
}

/**
 * Computes parameter adjustment for static methods
 * Returns 1 for static methods, 0 otherwise
 */
int static_method_adjustment(Function method) {
  if DD::isStaticmethod(method) then result = 1 else result = 0
}

// Checks for incorrect special method definitions
predicate has_incorrect_signature(
  Function method, string errorMsg, boolean showParamCounts, string methodName, boolean hasUnusedDefaults
) {
  exists(int expectedArgs, int staticAdjust |
    expectedArgs = expected_arg_count(methodName) - staticAdjust and
    staticAdjust = static_method_adjustment(method)
  |
    /* Handle insufficient parameters */
    if expectedArgs > method.getMaxPositionalArguments()
    then errorMsg = "Too few parameters" and showParamCounts = true and hasUnusedDefaults = false
    else
      /* Handle excessive parameters */
      if expectedArgs < method.getMinPositionalArguments()
      then errorMsg = "Too many parameters" and showParamCounts = true and hasUnusedDefaults = false
      else (
        /* Handle unused default parameters */
        method.getMinPositionalArguments() < expectedArgs and
        not method.hasVarArg() and
        errorMsg =
          (expectedArgs - method.getMinPositionalArguments()) + " default value(s) will never be used" and
        showParamCounts = false and
        hasUnusedDefaults = true
      )
  )
}

// Checks for incorrect __pow__ method signatures
predicate has_incorrect_pow_signature(
  Function method, string errorMsg, boolean showParamCounts, boolean hasUnusedDefaults
) {
  exists(int staticAdjust | staticAdjust = static_method_adjustment(method) |
    /* Insufficient parameters */
    method.getMaxPositionalArguments() < 2 - staticAdjust and
    errorMsg = "Too few parameters" and
    showParamCounts = true and
    hasUnusedDefaults = false
    or
    /* Excessive parameters */
    method.getMinPositionalArguments() > 3 - staticAdjust and
    errorMsg = "Too many parameters" and
    showParamCounts = true and
    hasUnusedDefaults = false
    or
    /* Unused default parameters */
    method.getMinPositionalArguments() < 2 - staticAdjust and
    errorMsg = (2 - method.getMinPositionalArguments()) + " default value(s) will never be used" and
    showParamCounts = false and
    hasUnusedDefaults = true
    or
    /* Missing default for third parameter */
    method.getMinPositionalArguments() = 3 - staticAdjust and
    errorMsg = "Third parameter to __pow__ should have a default value" and
    showParamCounts = false and
    hasUnusedDefaults = false
  )
}

// Checks for incorrect __round__ method signatures
predicate has_incorrect_round_signature(
  Function method, string errorMsg, boolean showParamCounts, boolean hasUnusedDefaults
) {
  exists(int staticAdjust | staticAdjust = static_method_adjustment(method) |
    /* Insufficient parameters */
    method.getMaxPositionalArguments() < 1 - staticAdjust and
    errorMsg = "Too few parameters" and
    showParamCounts = true and
    hasUnusedDefaults = false
    or
    /* Excessive parameters */
    method.getMinPositionalArguments() > 2 - staticAdjust and
    errorMsg = "Too many parameters" and
    showParamCounts = true and
    hasUnusedDefaults = false
    or
    /* Missing default for second parameter */
    method.getMinPositionalArguments() = 2 - staticAdjust and
    errorMsg = "Second parameter to __round__ should have a default value" and
    showParamCounts = false and
    hasUnusedDefaults = false
  )
}

// Checks for incorrect __get__ method signatures
predicate has_incorrect_get_signature(
  Function method, string errorMsg, boolean showParamCounts, boolean hasUnusedDefaults
) {
  exists(int staticAdjust | staticAdjust = static_method_adjustment(method) |
    /* Insufficient parameters */
    method.getMaxPositionalArguments() < 3 - staticAdjust and
    errorMsg = "Too few parameters" and
    showParamCounts = true and
    hasUnusedDefaults = false
    or
    /* Excessive parameters */
    method.getMinPositionalArguments() > 3 - staticAdjust and
    errorMsg = "Too many parameters" and
    showParamCounts = true and
    hasUnusedDefaults = false
    or
    /* Unused default parameters */
    method.getMinPositionalArguments() < 2 - staticAdjust and
    not method.hasVarArg() and
    errorMsg = (2 - method.getMinPositionalArguments()) + " default value(s) will never be used" and
    showParamCounts = false and
    hasUnusedDefaults = true
  )
}

// Generates expected parameter count description
string expected_param_description(string methodName) {
  if methodName in ["__pow__", "__get__"]
  then result = "2 or 3"
  else result = expected_arg_count(methodName).toString()
}

// Generates actual parameter count description
string actual_param_description(Function method) {
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
  // Single-statement function body
  method.getBody().getItem(0) = method.getBody().getLastItem() and
  (
    // String literal body (common in Zope interfaces)
    method.getBody().getLastItem().(ExprStmt).getValue() instanceof StringLiteral
    or
    // Exception-raising body
    method.getBody().getLastItem() instanceof Raise
    or
    // Pass statement body
    method.getBody().getLastItem() instanceof Pass
  )
}

from
  Function method, string errorMsg, string paramInfo, boolean showParamCounts, string methodName, 
  Class ownerClass, boolean hasUnusedDefaults
where
  ownerClass.getAMethod() = method and
  method.getName() = methodName and
  (
    has_incorrect_signature(method, errorMsg, showParamCounts, methodName, hasUnusedDefaults)
    or
    has_incorrect_pow_signature(method, errorMsg, showParamCounts, hasUnusedDefaults) and methodName = "__pow__"
    or
    has_incorrect_get_signature(method, errorMsg, showParamCounts, hasUnusedDefaults) and methodName = "__get__"
    or
    has_incorrect_round_signature(method, errorMsg, showParamCounts, hasUnusedDefaults) and methodName = "__round__"
  ) and
  not is_placeholder_function(method) and
  hasUnusedDefaults = false and
  (
    showParamCounts = false and paramInfo = ""
    or
    showParamCounts = true and 
    paramInfo = ", which has " + actual_param_description(method) + 
                ", but should have " + expected_param_description(methodName)
  )
select method, errorMsg + " for special method " + methodName + paramInfo + ", in class $@.", 
       ownerClass, ownerClass.getName()