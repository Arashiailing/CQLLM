/**
 * @name Type metrics
 * @description Computes metrics for different kinds of type annotations in Python code, 
 *              including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents built-in Python types
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr func) { exists(func.getReturns()) } or
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign stmt) { exists(stmt.getAnnotation()) }

// Abstract base class for type-annotated elements
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
  AnnAssign annotatedAssign;

  AnnotatedAssignment() { this = TAnnotatedAssignment(annotatedAssign) }
  override Expr getAnnotation() { result = annotatedAssign.getAnnotation() }
}

/** Holds if `annotationExpr` is a forward declaration using string literal */
predicate is_forward_declaration(Expr annotationExpr) { 
  annotationExpr instanceof StringLiteral 
}

/** Holds if `annotationExpr` represents a complex type construct */
predicate is_complex_type(Expr annotationExpr) {
  (annotationExpr instanceof Subscript and not is_optional_type(annotationExpr)) or
  annotationExpr instanceof Tuple or
  annotationExpr instanceof List
}

/** Holds if `annotationExpr` is an Optional type annotation */
predicate is_optional_type(Subscript annotationExpr) { 
  annotationExpr.getObject().(Name).getId() = "Optional" 
}

/** Holds if `annotationExpr` is a simple non-built-in type identifier */
predicate is_simple_type(Expr annotationExpr) {
  (annotationExpr instanceof Name and not annotationExpr instanceof BuiltinType) or
  (annotationExpr instanceof Attribute and is_simple_type(annotationExpr.(Attribute).getObject()))
}

/** Holds if `annotationExpr` is a built-in type */
predicate is_builtin_type(Expr annotationExpr) { 
  annotationExpr instanceof BuiltinType 
}

// Calculates type annotation metrics for each annotation category
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

// Main query execution
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  type_annotation_metrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount