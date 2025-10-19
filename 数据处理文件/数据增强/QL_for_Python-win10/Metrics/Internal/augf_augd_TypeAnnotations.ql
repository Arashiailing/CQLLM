/**
 * @name Python Type Annotation Metrics
 * @description Provides statistics on different categories of type annotations used in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types
class PythonBuiltinType extends Name {
  PythonBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for all annotatable Python constructs
newtype TypeAnnotatableElement =
  TFunctionWithReturnType(FunctionExpr f) { exists(f.getReturns()) } or 
  TParameterWithType(Parameter p) { exists(p.getAnnotation()) } or 
  TVariableWithTypeAnnotation(AnnAssign a) { exists(a.getAnnotation()) }

// Base class for all annotatable elements
abstract class TypeAnnotatable extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotatable" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, TypeAnnotatable {
  FunctionExpr func;
  FunctionWithReturnType() { this = TFunctionWithReturnType(func) }
  override Expr getAnnotation() { result = func.getReturns() }
}

// Represents parameters with type annotations
class ParameterWithType extends TParameterWithType, TypeAnnotatable {
  Parameter param;
  ParameterWithType() { this = TParameterWithType(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Represents variable assignments with type annotations
class VariableWithTypeAnnotation extends TVariableWithTypeAnnotation, TypeAnnotatable {
  AnnAssign assign;
  VariableWithTypeAnnotation() { this = TVariableWithTypeAnnotation(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

// Type annotation classification predicates

/** Checks if an expression is a forward-declared type (string literal) */
predicate isStringLiteralType(Expr expr) { expr instanceof StringLiteral }

/** Checks if an expression represents a complex type that's hard to analyze */
predicate isComplexTypeExpr(Expr expr) {
  expr instanceof Subscript and not isOptionalTypeExpr(expr) or
  expr instanceof Tuple or
  expr instanceof List
}

/** Checks if an expression is an Optional[...] type */
predicate isOptionalTypeExpr(Expr expr) {
  expr instanceof Subscript and
  expr.(Subscript).getObject().(Name).getId() = "Optional"
}

/** Checks if an expression is a simple type (non-builtin identifier or attribute) */
predicate isSimpleTypeExpr(Expr expr) {
  expr instanceof Name and not expr instanceof PythonBuiltinType
  or
  exists(Expr obj | obj = expr.(Attribute).getObject() and isSimpleTypeExpr(obj))
}

/** Checks if an expression represents a built-in type */
predicate isBuiltinTypeExpr(Expr expr) { expr instanceof PythonBuiltinType }

// Helper predicates for counting different types of annotations

predicate countParameterAnnotations(int total, int builtin, int forward, int simple, int complex, int optional) {
  total = count(ParameterWithType p) and
  builtin = count(ParameterWithType p | isBuiltinTypeExpr(p.getAnnotation())) and
  forward = count(ParameterWithType p | isStringLiteralType(p.getAnnotation())) and
  simple = count(ParameterWithType p | isSimpleTypeExpr(p.getAnnotation())) and
  complex = count(ParameterWithType p | isComplexTypeExpr(p.getAnnotation())) and
  optional = count(ParameterWithType p | isOptionalTypeExpr(p.getAnnotation()))
}

predicate countReturnAnnotations(int total, int builtin, int forward, int simple, int complex, int optional) {
  total = count(FunctionWithReturnType f) and
  builtin = count(FunctionWithReturnType f | isBuiltinTypeExpr(f.getAnnotation())) and
  forward = count(FunctionWithReturnType f | isStringLiteralType(f.getAnnotation())) and
  simple = count(FunctionWithReturnType f | isSimpleTypeExpr(f.getAnnotation())) and
  complex = count(FunctionWithReturnType f | isComplexTypeExpr(f.getAnnotation())) and
  optional = count(FunctionWithReturnType f | isOptionalTypeExpr(f.getAnnotation()))
}

predicate countAssignmentAnnotations(int total, int builtin, int forward, int simple, int complex, int optional) {
  total = count(VariableWithTypeAnnotation a) and
  builtin = count(VariableWithTypeAnnotation a | isBuiltinTypeExpr(a.getAnnotation())) and
  forward = count(VariableWithTypeAnnotation a | isStringLiteralType(a.getAnnotation())) and
  simple = count(VariableWithTypeAnnotation a | isSimpleTypeExpr(a.getAnnotation())) and
  complex = count(VariableWithTypeAnnotation a | isComplexTypeExpr(a.getAnnotation())) and
  optional = count(VariableWithTypeAnnotation a | isOptionalTypeExpr(a.getAnnotation()))
}

// Main predicate that calculates type annotation metrics for different categories
predicate calculateTypeMetrics(
  string category, int total, int builtin, int forward, int simple, 
  int complex, int optional
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  countParameterAnnotations(total, builtin, forward, simple, complex, optional)
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  countReturnAnnotations(total, builtin, forward, simple, complex, optional)
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  countAssignmentAnnotations(total, builtin, forward, simple, complex, optional)
}

from
  string category, int total, int builtin, int forward, int simple, int complex, int optional
where calculateTypeMetrics(category, total, builtin, forward, simple, complex, optional)
select category, total, builtin, forward, simple, complex, optional