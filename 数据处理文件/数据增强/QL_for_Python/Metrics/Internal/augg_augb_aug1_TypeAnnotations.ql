/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code
 * @kind table
 * @id py/type-metrics
 */

import python

// Core Python built-in types
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or 
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign annAssign) { exists(annAssign.getAnnotation()) }

// Base class for elements with type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Functions with return type annotations
class AnnotatedFunction extends TAnnotatedFunction, Annotatable {
  FunctionExpr funcExpr;
  AnnotatedFunction() { this = TAnnotatedFunction(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter param;
  AnnotatedParameter() { this = TAnnotatedParameter(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignments with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign annAssign;
  AnnotatedAssignment() { this = TAnnotatedAssignment(annAssign) }
  override Expr getAnnotation() { result = annAssign.getAnnotation() }
}

/** Check if annotation is a forward-declared type (string literal) */
predicate is_forward_declaration(Expr annoExpr) { annoExpr instanceof StringLiteral }

/** Check if annotation represents a complex type structure */
predicate is_complex_type(Expr annoExpr) {
  annoExpr instanceof Subscript and not is_optional_type(annoExpr)
  or
  annoExpr instanceof Tuple
  or
  annoExpr instanceof List
}

/** Check if annotation is an Optional type */
predicate is_optional_type(Subscript annoExpr) { annoExpr.getObject().(Name).getId() = "Optional" }

/** Check if annotation is a simple user-defined type */
predicate is_simple_type(Expr annoExpr) {
  annoExpr instanceof Name and not annoExpr instanceof BuiltinType
  or
  is_simple_type(annoExpr.(Attribute).getObject())
}

/** Check if annotation is a built-in type */
predicate is_builtin_type(Expr annoExpr) { annoExpr instanceof BuiltinType }

// Calculate type annotation metrics for different categories
predicate type_count(
  string category, int total, int builtin, int forward, 
  int simple, int complex, int optional
) {
  // Parameter annotations
  category = "Parameter annotation" and
  total = count(AnnotatedParameter annotatedParam) and
  builtin = count(AnnotatedParameter annotatedParam | is_builtin_type(annotatedParam.getAnnotation())) and
  forward = count(AnnotatedParameter annotatedParam | is_forward_declaration(annotatedParam.getAnnotation())) and
  simple = count(AnnotatedParameter annotatedParam | is_simple_type(annotatedParam.getAnnotation())) and
  complex = count(AnnotatedParameter annotatedParam | is_complex_type(annotatedParam.getAnnotation())) and
  optional = count(AnnotatedParameter annotatedParam | is_optional_type(annotatedParam.getAnnotation()))
  or
  // Return type annotations
  category = "Return type annotation" and
  total = count(AnnotatedFunction annotatedFunc) and
  builtin = count(AnnotatedFunction annotatedFunc | is_builtin_type(annotatedFunc.getAnnotation())) and
  forward = count(AnnotatedFunction annotatedFunc | is_forward_declaration(annotatedFunc.getAnnotation())) and
  simple = count(AnnotatedFunction annotatedFunc | is_simple_type(annotatedFunc.getAnnotation())) and
  complex = count(AnnotatedFunction annotatedFunc | is_complex_type(annotatedFunc.getAnnotation())) and
  optional = count(AnnotatedFunction annotatedFunc | is_optional_type(annotatedFunc.getAnnotation()))
  or
  // Annotated assignments
  category = "Annotated assignment" and
  total = count(AnnotatedAssignment annotatedAssign) and
  builtin = count(AnnotatedAssignment annotatedAssign | is_builtin_type(annotatedAssign.getAnnotation())) and
  forward = count(AnnotatedAssignment annotatedAssign | is_forward_declaration(annotatedAssign.getAnnotation())) and
  simple = count(AnnotatedAssignment annotatedAssign | is_simple_type(annotatedAssign.getAnnotation())) and
  complex = count(AnnotatedAssignment annotatedAssign | is_complex_type(annotatedAssign.getAnnotation())) and
  optional = count(AnnotatedAssignment annotatedAssign | is_optional_type(annotatedAssign.getAnnotation()))
}

// Query execution and result projection
from
  string category, int total, int builtin, int forward, int simple, int complex, int optional
where type_count(category, total, builtin, forward, simple, complex, optional)
select category, total, builtin, forward, simple, complex, optional