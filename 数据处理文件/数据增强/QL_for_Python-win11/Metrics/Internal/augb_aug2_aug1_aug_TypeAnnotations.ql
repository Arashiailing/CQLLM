/**
 * @name Type metrics
 * @description Quantifies different types of type annotations in Python code,
 *              including parameter annotations, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types (e.g., int, str, bool)
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class Annotatable extends TAnnotatable {
  string toString() { result = "Annotatable" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
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

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assign;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

/** Holds if `annotExpr` is a forward-declared type (string literal). */
predicate is_forward_declaration(Expr annotExpr) { annotExpr instanceof StringLiteral }

/** Holds if `annotExpr` is a complex type that may be difficult to analyze. */
predicate is_complex_type(Expr annotExpr) {
  (annotExpr instanceof Subscript and not is_optional_type(annotExpr)) or
  annotExpr instanceof Tuple or
  annotExpr instanceof List
}

/** Holds if `annotExpr` is an Optional type (e.g., Optional[...]). */
predicate is_optional_type(Subscript annotExpr) { annotExpr.getObject().(Name).getId() = "Optional" }

/** Holds if `annotExpr` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr annotExpr) {
  (annotExpr instanceof Name and not annotExpr instanceof BuiltinType) or
  is_simple_type(annotExpr.(Attribute).getObject())
}

/** Holds if `annotExpr` is a built-in type. */
predicate is_builtin_type(Expr annotExpr) { annotExpr instanceof BuiltinType }

// Computes metrics for different categories of type annotations
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter annotatedParam) and
  builtinCount = count(AnnotatedParameter annotatedParam | is_builtin_type(annotatedParam.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter annotatedParam | is_forward_declaration(annotatedParam.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter annotatedParam | is_simple_type(annotatedParam.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter annotatedParam | is_complex_type(annotatedParam.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter annotatedParam | is_optional_type(annotatedParam.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction annotatedFunc) and
  builtinCount = count(AnnotatedFunction annotatedFunc | is_builtin_type(annotatedFunc.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction annotatedFunc | is_forward_declaration(annotatedFunc.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction annotatedFunc | is_simple_type(annotatedFunc.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction annotatedFunc | is_complex_type(annotatedFunc.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction annotatedFunc | is_optional_type(annotatedFunc.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment annotatedAssign) and
  builtinCount = count(AnnotatedAssignment annotatedAssign | is_builtin_type(annotatedAssign.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment annotatedAssign | is_forward_declaration(annotatedAssign.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment annotatedAssign | is_simple_type(annotatedAssign.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment annotatedAssign | is_complex_type(annotatedAssign.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment annotatedAssign | is_optional_type(annotatedAssign.getAnnotation()))
}

// Query execution and results output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  type_annotation_metrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount