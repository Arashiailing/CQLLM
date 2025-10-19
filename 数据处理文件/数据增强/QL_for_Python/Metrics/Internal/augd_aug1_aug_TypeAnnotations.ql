/**
 * @name Type metrics
 * @description Provides counts of different kinds of type annotations in Python code, 
 *              including parameters, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents a built-in type in Python (e.g., int, str, bool)
class IntrinsicType extends Name {
  IntrinsicType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TypeAnnotatedElement =
  TFunctionWithReturnType(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TParameterWithType(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAssignmentWithType(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class BaseAnnotatedElement extends TypeAnnotatedElement {
  string toString() { result = "BaseAnnotatedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, BaseAnnotatedElement {
  FunctionExpr functionExpr;

  FunctionWithReturnType() { this = TFunctionWithReturnType(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class ParameterWithType extends TParameterWithType, BaseAnnotatedElement {
  Parameter parameter;

  ParameterWithType() { this = TParameterWithType(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithType extends TAssignmentWithType, BaseAnnotatedElement {
  AnnAssign assignment;

  AssignmentWithType() { this = TAssignmentWithType(assignment) }
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
  (typeExpr instanceof Name and not typeExpr instanceof IntrinsicType) or
  is_simple_type(typeExpr.(Attribute).getObject())
}

/** Holds if `typeExpr` is a built-in type. */
predicate is_builtin_type(Expr typeExpr) { typeExpr instanceof IntrinsicType }

// Computes type annotation metrics for different annotation categories
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  (
    // Parameter annotation metrics
    category = "Parameter annotation" and
    totalCount = count(ParameterWithType p) and
    builtinCount = count(ParameterWithType p | is_builtin_type(p.getAnnotation())) and
    forwardDeclCount = count(ParameterWithType p | is_forward_declaration(p.getAnnotation())) and
    simpleTypeCount = count(ParameterWithType p | is_simple_type(p.getAnnotation())) and
    complexTypeCount = count(ParameterWithType p | is_complex_type(p.getAnnotation())) and
    optionalTypeCount = count(ParameterWithType p | is_optional_type(p.getAnnotation()))
  ) or (
    // Return type annotation metrics
    category = "Return type annotation" and
    totalCount = count(FunctionWithReturnType f) and
    builtinCount = count(FunctionWithReturnType f | is_builtin_type(f.getAnnotation())) and
    forwardDeclCount = count(FunctionWithReturnType f | is_forward_declaration(f.getAnnotation())) and
    simpleTypeCount = count(FunctionWithReturnType f | is_simple_type(f.getAnnotation())) and
    complexTypeCount = count(FunctionWithReturnType f | is_complex_type(f.getAnnotation())) and
    optionalTypeCount = count(FunctionWithReturnType f | is_optional_type(f.getAnnotation()))
  ) or (
    // Annotated assignment metrics
    category = "Annotated assignment" and
    totalCount = count(AssignmentWithType a) and
    builtinCount = count(AssignmentWithType a | is_builtin_type(a.getAnnotation())) and
    forwardDeclCount = count(AssignmentWithType a | is_forward_declaration(a.getAnnotation())) and
    simpleTypeCount = count(AssignmentWithType a | is_simple_type(a.getAnnotation())) and
    complexTypeCount = count(AssignmentWithType a | is_complex_type(a.getAnnotation())) and
    optionalTypeCount = count(AssignmentWithType a | is_optional_type(a.getAnnotation()))
  )
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