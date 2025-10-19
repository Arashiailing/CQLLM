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
  TAnnotatedFunction(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or 
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or 
  TAnnotatedAssignment(AnnAssign annotAssign) { exists(annotAssign.getAnnotation()) }

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
  AnnAssign annotAssign;
  AnnotatedAssignment() { this = TAnnotatedAssignment(annotAssign) }
  override Expr getAnnotation() { result = annotAssign.getAnnotation() }
}

// Type classification predicates
/** Identifies forward-declared types (string literals) */
predicate is_forward_declaration(Expr annotationExpr) { 
  annotationExpr instanceof StringLiteral 
}

/** Identifies complex type structures */
predicate is_complex_type(Expr annotationExpr) {
  (annotationExpr instanceof Subscript and not is_optional_type(annotationExpr))
  or
  annotationExpr instanceof Tuple
  or
  annotationExpr instanceof List
}

/** Identifies Optional types */
predicate is_optional_type(Subscript annotationExpr) { 
  annotationExpr.getObject().(Name).getId() = "Optional" 
}

/** Identifies simple user-defined types */
predicate is_simple_type(Expr annotationExpr) {
  (annotationExpr instanceof Name and not annotationExpr instanceof BuiltinType)
  or
  is_simple_type(annotationExpr.(Attribute).getObject())
}

/** Identifies built-in types */
predicate is_builtin_type(Expr annotationExpr) { 
  annotationExpr instanceof BuiltinType 
}

// Computes type annotation metrics for different annotation categories
predicate type_count(
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

// Query execution and result projection
from
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  type_count(category, totalCount, builtinCount, forwardDeclCount, simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount