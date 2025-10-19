/**
 * @name Type metrics
 * @description Analyzes and counts different categories of type annotations in Python code,
 *              including parameter annotations, return type annotations, and annotated assignments.
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
  TAnnotatedFunction(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or
  TAnnotatedParameter(Parameter param) { exists(param.getAnnotation()) } or
  TAnnotatedAssignment(AnnAssign annotAssign) { exists(annotAssign.getAnnotation()) }

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
  AnnAssign annotAssign;

  AnnotatedAssignment() { this = TAnnotatedAssignment(annotAssign) }
  override Expr getAnnotation() { result = annotAssign.getAnnotation() }
}

// Type classification predicates
/** Holds if `typeAnnotation` is a forward declaration (string literal) of a type. */
predicate is_forward_declaration(Expr typeAnnotation) { typeAnnotation instanceof StringLiteral }

/** Holds if `typeAnnotation` is a type that may be difficult to analyze. */
predicate is_complex_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Subscript and not is_optional_type(typeAnnotation)) or
  typeAnnotation instanceof Tuple or
  typeAnnotation instanceof List
}

/** Holds if `typeAnnotation` is a type of the form `Optional[...]`. */
predicate is_optional_type(Subscript typeAnnotation) { typeAnnotation.getObject().(Name).getId() = "Optional" }

/** Holds if `typeAnnotation` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Name and not typeAnnotation instanceof BuiltinType) or
  is_simple_type(typeAnnotation.(Attribute).getObject())
}

/** Holds if `typeAnnotation` is a built-in type. */
predicate is_builtin_type(Expr typeAnnotation) { typeAnnotation instanceof BuiltinType }

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