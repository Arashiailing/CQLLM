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
  FunctionExpr functionExpr;

  AnnotatedFunction() { this = TAnnotatedFunction(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class AnnotatedParameter extends TAnnotatedParameter, Annotatable {
  Parameter parameter;

  AnnotatedParameter() { this = TAnnotatedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AnnotatedAssignment extends TAnnotatedAssignment, Annotatable {
  AnnAssign assignmentStmt;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assignmentStmt) }
  override Expr getAnnotation() { result = assignmentStmt.getAnnotation() }
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
  totalCount = count(AnnotatedParameter param) and
  builtinCount = count(AnnotatedParameter param | is_builtin_type(param.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter param | is_forward_declaration(param.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter param | is_simple_type(param.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter param | is_complex_type(param.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter param | is_optional_type(param.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction func) and
  builtinCount = count(AnnotatedFunction func | is_builtin_type(func.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction func | is_forward_declaration(func.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction func | is_simple_type(func.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction func | is_complex_type(func.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction func | is_optional_type(func.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment assign) and
  builtinCount = count(AnnotatedAssignment assign | is_builtin_type(assign.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment assign | is_forward_declaration(assign.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment assign | is_simple_type(assign.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment assign | is_complex_type(assign.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment assign | is_optional_type(assign.getAnnotation()))
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