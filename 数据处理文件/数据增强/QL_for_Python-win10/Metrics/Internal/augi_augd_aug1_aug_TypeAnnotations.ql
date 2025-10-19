/**
 * @name Type metrics
 * @description Analyzes and counts various forms of type annotations in Python code,
 *              covering function parameters, return types, and variable assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a built-in type in Python (e.g., int, str, bool)
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TypedElement =
  TTypedFunction(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TTypedParameter(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TTypedAssignment(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class BaseTypedElement extends TypedElement {
  string toString() { result = "BaseTypedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class TypedFunction extends TTypedFunction, BaseTypedElement {
  FunctionExpr functionExpr;

  TypedFunction() { this = TTypedFunction(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class TypedParameter extends TTypedParameter, BaseTypedElement {
  Parameter parameter;

  TypedParameter() { this = TTypedParameter(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class TypedAssignment extends TTypedAssignment, BaseTypedElement {
  AnnAssign assignment;

  TypedAssignment() { this = TTypedAssignment(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

// Helper predicates for type annotation classification

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
predicate compute_type_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  (
    // Parameter annotation metrics
    category = "Parameter annotation" and
    totalCount = count(TypedParameter p) and
    builtinCount = count(TypedParameter p | is_builtin_type(p.getAnnotation())) and
    forwardDeclCount = count(TypedParameter p | is_forward_declaration(p.getAnnotation())) and
    simpleTypeCount = count(TypedParameter p | is_simple_type(p.getAnnotation())) and
    complexTypeCount = count(TypedParameter p | is_complex_type(p.getAnnotation())) and
    optionalTypeCount = count(TypedParameter p | is_optional_type(p.getAnnotation()))
  ) or (
    // Return type annotation metrics
    category = "Return type annotation" and
    totalCount = count(TypedFunction f) and
    builtinCount = count(TypedFunction f | is_builtin_type(f.getAnnotation())) and
    forwardDeclCount = count(TypedFunction f | is_forward_declaration(f.getAnnotation())) and
    simpleTypeCount = count(TypedFunction f | is_simple_type(f.getAnnotation())) and
    complexTypeCount = count(TypedFunction f | is_complex_type(f.getAnnotation())) and
    optionalTypeCount = count(TypedFunction f | is_optional_type(f.getAnnotation()))
  ) or (
    // Annotated assignment metrics
    category = "Annotated assignment" and
    totalCount = count(TypedAssignment a) and
    builtinCount = count(TypedAssignment a | is_builtin_type(a.getAnnotation())) and
    forwardDeclCount = count(TypedAssignment a | is_forward_declaration(a.getAnnotation())) and
    simpleTypeCount = count(TypedAssignment a | is_simple_type(a.getAnnotation())) and
    complexTypeCount = count(TypedAssignment a | is_complex_type(a.getAnnotation())) and
    optionalTypeCount = count(TypedAssignment a | is_optional_type(a.getAnnotation()))
  )
}

// Query execution and output
from 
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
where 
  compute_type_metrics(category, totalCount, builtinCount, forwardDeclCount, 
                       simpleTypeCount, complexTypeCount, optionalTypeCount)
select 
  category, totalCount, builtinCount, forwardDeclCount, 
  simpleTypeCount, complexTypeCount, optionalTypeCount