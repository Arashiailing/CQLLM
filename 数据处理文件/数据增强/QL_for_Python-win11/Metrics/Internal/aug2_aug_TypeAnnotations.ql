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
  FunctionExpr func;

  AnnotatedFunction() { this = TAnnotatedFunction(func) }
  override Expr getAnnotation() { result = func.getReturns() }
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

/** Holds if `e` is a forward declaration using string literal */
predicate is_forward_declaration(Expr e) { e instanceof StringLiteral }

/** Holds if `e` represents a complex type construct */
predicate is_complex_type(Expr e) {
  e instanceof Subscript and not is_optional_type(e) or
  e instanceof Tuple or
  e instanceof List
}

/** Holds if `e` is an Optional type annotation */
predicate is_optional_type(Subscript e) { e.getObject().(Name).getId() = "Optional" }

/** Holds if `e` is a simple non-built-in type identifier */
predicate is_simple_type(Expr e) {
  e instanceof Name and not e instanceof BuiltinType or
  is_simple_type(e.(Attribute).getObject())
}

/** Holds if `e` is a built-in type */
predicate is_builtin_type(Expr e) { e instanceof BuiltinType }

// Calculates type annotation metrics for each annotation category
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  category = "Parameter annotation" and
  totalCount = count(AnnotatedParameter p) and
  builtinCount = count(AnnotatedParameter p | is_builtin_type(p.getAnnotation())) and
  forwardDeclCount = count(AnnotatedParameter p | is_forward_declaration(p.getAnnotation())) and
  simpleTypeCount = count(AnnotatedParameter p | is_simple_type(p.getAnnotation())) and
  complexTypeCount = count(AnnotatedParameter p | is_complex_type(p.getAnnotation())) and
  optionalTypeCount = count(AnnotatedParameter p | is_optional_type(p.getAnnotation()))
  or
  // Return type annotation metrics
  category = "Return type annotation" and
  totalCount = count(AnnotatedFunction f) and
  builtinCount = count(AnnotatedFunction f | is_builtin_type(f.getAnnotation())) and
  forwardDeclCount = count(AnnotatedFunction f | is_forward_declaration(f.getAnnotation())) and
  simpleTypeCount = count(AnnotatedFunction f | is_simple_type(f.getAnnotation())) and
  complexTypeCount = count(AnnotatedFunction f | is_complex_type(f.getAnnotation())) and
  optionalTypeCount = count(AnnotatedFunction f | is_optional_type(f.getAnnotation()))
  or
  // Annotated assignment metrics
  category = "Annotated assignment" and
  totalCount = count(AnnotatedAssignment a) and
  builtinCount = count(AnnotatedAssignment a | is_builtin_type(a.getAnnotation())) and
  forwardDeclCount = count(AnnotatedAssignment a | is_forward_declaration(a.getAnnotation())) and
  simpleTypeCount = count(AnnotatedAssignment a | is_simple_type(a.getAnnotation())) and
  complexTypeCount = count(AnnotatedAssignment a | is_complex_type(a.getAnnotation())) and
  optionalTypeCount = count(AnnotatedAssignment a | is_optional_type(a.getAnnotation()))
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