/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code
 * @kind table
 * @id py/type-metrics
 */

import python

// Core Python built-in types for type annotation analysis
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or 
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign annotatedAssign) { exists(annotatedAssign.getAnnotation()) }

// Base class for elements that can have type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr functionExpression;
  AnnotatedFunction() { this = TAnnotatedFunction(functionExpression) }
  override Expr getAnnotation() { result = functionExpression.getReturns() }
}

// Represents parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter parameter;
  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents assignments with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign annotatedAssignment;
  AnnotatedAssignment() { this = TAnnotatedAssignment(annotatedAssignment) }
  override Expr getAnnotation() { result = annotatedAssignment.getAnnotation() }
}

// Type classification predicates
/** Determines if an annotation is a forward-declared type (string literal) */
predicate is_forward_declaration(Expr annotationExpr) { annotationExpr instanceof StringLiteral }

/** Determines if an annotation represents a complex type structure */
predicate is_complex_type(Expr annotationExpr) {
  annotationExpr instanceof Subscript and not is_optional_type(annotationExpr)
  or
  annotationExpr instanceof Tuple
  or
  annotationExpr instanceof List
}

/** Determines if an annotation is an Optional type */
predicate is_optional_type(Subscript annotationExpr) { annotationExpr.getObject().(Name).getId() = "Optional" }

/** Determines if an annotation is a simple user-defined type */
predicate is_simple_type(Expr annotationExpr) {
  annotationExpr instanceof Name and not annotationExpr instanceof BuiltinType
  or
  is_simple_type(annotationExpr.(Attribute).getObject())
}

/** Determines if an annotation is a built-in type */
predicate is_builtin_type(Expr annotationExpr) { annotationExpr instanceof BuiltinType }

// Computes type annotation metrics for different annotation categories
predicate type_count(
  string kind, int total, int built_in, int forward_decl, 
  int simple, int complex, int optional
) {
  // Parameter annotation metrics
  kind = "Parameter annotation" and
  total = count(AnnotatedParameter annotatedParam) and
  built_in = count(AnnotatedParameter annotatedParam | is_builtin_type(annotatedParam.getAnnotation())) and
  forward_decl = count(AnnotatedParameter annotatedParam | is_forward_declaration(annotatedParam.getAnnotation())) and
  simple = count(AnnotatedParameter annotatedParam | is_simple_type(annotatedParam.getAnnotation())) and
  complex = count(AnnotatedParameter annotatedParam | is_complex_type(annotatedParam.getAnnotation())) and
  optional = count(AnnotatedParameter annotatedParam | is_optional_type(annotatedParam.getAnnotation()))
  or
  // Return type annotation metrics
  kind = "Return type annotation" and
  total = count(AnnotatedFunction annotatedFunc) and
  built_in = count(AnnotatedFunction annotatedFunc | is_builtin_type(annotatedFunc.getAnnotation())) and
  forward_decl = count(AnnotatedFunction annotatedFunc | is_forward_declaration(annotatedFunc.getAnnotation())) and
  simple = count(AnnotatedFunction annotatedFunc | is_simple_type(annotatedFunc.getAnnotation())) and
  complex = count(AnnotatedFunction annotatedFunc | is_complex_type(annotatedFunc.getAnnotation())) and
  optional = count(AnnotatedFunction annotatedFunc | is_optional_type(annotatedFunc.getAnnotation()))
  or
  // Annotated assignment metrics
  kind = "Annotated assignment" and
  total = count(AnnotatedAssignment annotatedAssign) and
  built_in = count(AnnotatedAssignment annotatedAssign | is_builtin_type(annotatedAssign.getAnnotation())) and
  forward_decl = count(AnnotatedAssignment annotatedAssign | is_forward_declaration(annotatedAssign.getAnnotation())) and
  simple = count(AnnotatedAssignment annotatedAssign | is_simple_type(annotatedAssign.getAnnotation())) and
  complex = count(AnnotatedAssignment annotatedAssign | is_complex_type(annotatedAssign.getAnnotation())) and
  optional = count(AnnotatedAssignment annotatedAssign | is_optional_type(annotatedAssign.getAnnotation()))
}

// Query execution and result projection
from
  string kind, int total, int built_in, int forward_decl, int simple, int complex, int optional
where type_count(kind, total, built_in, forward_decl, simple, complex, optional)
select kind, total, built_in, forward_decl, simple, complex, optional