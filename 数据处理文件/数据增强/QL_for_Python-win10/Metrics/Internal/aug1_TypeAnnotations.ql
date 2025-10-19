/**
 * @name Type metrics
 * @description Counts of various kinds of type annotations in Python code.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Defines union type for annotatable elements
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr func) { exists(func.getReturns()) } or 
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign assign) { exists(assign.getAnnotation()) }

// Base class for elements that can have type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr funcExpr;
  AnnotatedFunction() { this = TAnnotatedFunction(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Represents parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter param;
  AnnotatedParameter() { this = TAnnotatedParameter(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Represents assignments with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignStmt;
  AnnotatedAssignment() { this = TAnnotatedAssignment(assignStmt) }
  override Expr getAnnotation() { result = assignStmt.getAnnotation() }
}

/** Checks if expression is a forward-declared type (string literal) */
predicate is_forward_declaration(Expr expr) { expr instanceof StringLiteral }

/** Checks if expression represents a complex type structure */
predicate is_complex_type(Expr expr) {
  expr instanceof Subscript and not is_optional_type(expr)
  or
  expr instanceof Tuple
  or
  expr instanceof List
}

/** Checks if expression is an Optional type */
predicate is_optional_type(Subscript expr) { expr.getObject().(Name).getId() = "Optional" }

/** Checks if expression is a simple user-defined type */
predicate is_simple_type(Expr expr) {
  expr instanceof Name and not expr instanceof BuiltinType
  or
  is_simple_type(expr.(Attribute).getObject())
}

/** Checks if expression is a built-in type */
predicate is_builtin_type(Expr expr) { expr instanceof BuiltinType }

// Computes type annotation metrics for different categories
predicate type_count(
  string kind, int total, int built_in_count, int forward_declaration_count, 
  int simple_type_count, int complex_type_count, int optional_type_count
) {
  kind = "Parameter annotation" and
  total = count(AnnotatedParameter annotParam) and
  built_in_count = count(AnnotatedParameter annotParam | is_builtin_type(annotParam.getAnnotation())) and
  forward_declaration_count = count(AnnotatedParameter annotParam | is_forward_declaration(annotParam.getAnnotation())) and
  simple_type_count = count(AnnotatedParameter annotParam | is_simple_type(annotParam.getAnnotation())) and
  complex_type_count = count(AnnotatedParameter annotParam | is_complex_type(annotParam.getAnnotation())) and
  optional_type_count = count(AnnotatedParameter annotParam | is_optional_type(annotParam.getAnnotation()))
  or
  kind = "Return type annotation" and
  total = count(AnnotatedFunction annotFunc) and
  built_in_count = count(AnnotatedFunction annotFunc | is_builtin_type(annotFunc.getAnnotation())) and
  forward_declaration_count = count(AnnotatedFunction annotFunc | is_forward_declaration(annotFunc.getAnnotation())) and
  simple_type_count = count(AnnotatedFunction annotFunc | is_simple_type(annotFunc.getAnnotation())) and
  complex_type_count = count(AnnotatedFunction annotFunc | is_complex_type(annotFunc.getAnnotation())) and
  optional_type_count = count(AnnotatedFunction annotFunc | is_optional_type(annotFunc.getAnnotation()))
  or
  kind = "Annotated assignment" and
  total = count(AnnotatedAssignment annotAssign) and
  built_in_count = count(AnnotatedAssignment annotAssign | is_builtin_type(annotAssign.getAnnotation())) and
  forward_declaration_count = count(AnnotatedAssignment annotAssign | is_forward_declaration(annotAssign.getAnnotation())) and
  simple_type_count = count(AnnotatedAssignment annotAssign | is_simple_type(annotAssign.getAnnotation())) and
  complex_type_count = count(AnnotatedAssignment annotAssign | is_complex_type(annotAssign.getAnnotation())) and
  optional_type_count = count(AnnotatedAssignment annotAssign | is_optional_type(annotAssign.getAnnotation()))
}

// Query execution and result selection
from
  string message, int total, int built_in, int forward_decl, int simple, int complex, int optional
where type_count(message, total, built_in, forward_decl, simple, complex, optional)
select message, total, built_in, forward_decl, simple, complex, optional