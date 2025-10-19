/**
 * @name Type metrics
 * @description Provides counts of different kinds of type annotations in Python code, 
 *              including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a built-in type in Python (e.g., int, str, bool)
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TAnnotatable =
  TAnnotatedFunction(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TAnnotatedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
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
  AnnAssign assignment;

  AnnotatedAssignment() { this = TAnnotatedAssignment(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

/** Holds if `typeExpr` is a forward declaration (string literal) of a type. */
predicate is_forward_declaration(Expr typeExpr) { typeExpr instanceof StringLiteral }

/** Holds if `typeExpr` is a type that may be difficult to analyze. */
predicate is_complex_type(Expr typeExpr) {
  (typeExpr instanceof Subscript and not is_optional_type(typeExpr)) or
  typeExpr instanceof Tuple or
  typeExpr instanceof List
}

/** Holds if `typeExpr` is a type of the form `Optional[...]`. */
predicate is_optional_type(Subscript typeExpr) { typeExpr.getObject().(Name).getId() = "Optional" }

/** Holds if `typeExpr` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr typeExpr) {
  (typeExpr instanceof Name and not typeExpr instanceof BuiltinType) or
  is_simple_type(typeExpr.(Attribute).getObject())
}

/** Holds if `typeExpr` is a built-in type. */
predicate is_builtin_type(Expr typeExpr) { typeExpr instanceof BuiltinType }

// Computes type annotation metrics for different annotation categories
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

// Query execution and output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  type_annotation_metrics(category, totalCount, builtinCount, forwardDeclCount, 
                         simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount