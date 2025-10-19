/**
 * @name Type metrics
 * @description Provides a comprehensive analysis of type annotation usage in Python code,
 *              categorizing and quantifying parameter annotations, return types, and
 *              annotated assignments. This query generates metrics on built-in types,
 *              forward declarations, simple types, complex types, and optional types.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types (e.g., int, str, bool)
class BuiltinType extends Name {
  BuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TypeAnnotatableElement =
  TTypeAnnotatableFunctionElement(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TTypeAnnotatableParameterElement(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TTypeAnnotatableAssignmentElement(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class TypeAnnotationElement extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotationElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionTypeAnnotationElement extends TTypeAnnotatableFunctionElement, TypeAnnotationElement {
  FunctionExpr functionExpr;

  FunctionTypeAnnotationElement() { this = TTypeAnnotatableFunctionElement(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class ParameterTypeAnnotationElement extends TTypeAnnotatableParameterElement, TypeAnnotationElement {
  Parameter parameter;

  ParameterTypeAnnotationElement() { this = TTypeAnnotatableParameterElement(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentTypeAnnotationElement extends TTypeAnnotatableAssignmentElement, TypeAnnotationElement {
  AnnAssign assignment;

  AssignmentTypeAnnotationElement() { this = TTypeAnnotatableAssignmentElement(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

/** Determines if `typeAnnotation` is a forward-declared type (string literal). */
predicate is_forward_declaration(Expr typeAnnotation) { typeAnnotation instanceof StringLiteral }

/** Determines if `typeAnnotation` is a complex type that may be difficult to analyze. */
predicate is_complex_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Subscript and not is_optional_type(typeAnnotation)) or
  typeAnnotation instanceof Tuple or
  typeAnnotation instanceof List
}

/** Determines if `typeAnnotation` is an Optional type (e.g., Optional[...]). */
predicate is_optional_type(Subscript typeAnnotation) { typeAnnotation.getObject().(Name).getId() = "Optional" }

/** Determines if `typeAnnotation` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Name and not typeAnnotation instanceof BuiltinType) or
  is_simple_type(typeAnnotation.(Attribute).getObject())
}

/** Determines if `typeAnnotation` is a built-in type. */
predicate is_builtin_type(Expr typeAnnotation) { typeAnnotation instanceof BuiltinType }

// Computes metrics for parameter type annotations
predicate parameter_annotation_metrics(
  int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  totalCount = count(ParameterTypeAnnotationElement annotatedParameter) and
  builtinCount = count(ParameterTypeAnnotationElement annotatedParameter | is_builtin_type(annotatedParameter.getAnnotation())) and
  forwardDeclCount = count(ParameterTypeAnnotationElement annotatedParameter | is_forward_declaration(annotatedParameter.getAnnotation())) and
  simpleTypeCount = count(ParameterTypeAnnotationElement annotatedParameter | is_simple_type(annotatedParameter.getAnnotation())) and
  complexTypeCount = count(ParameterTypeAnnotationElement annotatedParameter | is_complex_type(annotatedParameter.getAnnotation())) and
  optionalTypeCount = count(ParameterTypeAnnotationElement annotatedParameter | is_optional_type(annotatedParameter.getAnnotation()))
}

// Computes metrics for return type annotations
predicate return_type_annotation_metrics(
  int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  totalCount = count(FunctionTypeAnnotationElement annotatedFunction) and
  builtinCount = count(FunctionTypeAnnotationElement annotatedFunction | is_builtin_type(annotatedFunction.getAnnotation())) and
  forwardDeclCount = count(FunctionTypeAnnotationElement annotatedFunction | is_forward_declaration(annotatedFunction.getAnnotation())) and
  simpleTypeCount = count(FunctionTypeAnnotationElement annotatedFunction | is_simple_type(annotatedFunction.getAnnotation())) and
  complexTypeCount = count(FunctionTypeAnnotationElement annotatedFunction | is_complex_type(annotatedFunction.getAnnotation())) and
  optionalTypeCount = count(FunctionTypeAnnotationElement annotatedFunction | is_optional_type(annotatedFunction.getAnnotation()))
}

// Computes metrics for annotated assignments
predicate assignment_annotation_metrics(
  int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  totalCount = count(AssignmentTypeAnnotationElement annotatedAssignment) and
  builtinCount = count(AssignmentTypeAnnotationElement annotatedAssignment | is_builtin_type(annotatedAssignment.getAnnotation())) and
  forwardDeclCount = count(AssignmentTypeAnnotationElement annotatedAssignment | is_forward_declaration(annotatedAssignment.getAnnotation())) and
  simpleTypeCount = count(AssignmentTypeAnnotationElement annotatedAssignment | is_simple_type(annotatedAssignment.getAnnotation())) and
  complexTypeCount = count(AssignmentTypeAnnotationElement annotatedAssignment | is_complex_type(annotatedAssignment.getAnnotation())) and
  optionalTypeCount = count(AssignmentTypeAnnotationElement annotatedAssignment | is_optional_type(annotatedAssignment.getAnnotation()))
}

// Combines metrics for all categories of type annotations
predicate type_annotation_metrics(
  string category, int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  (
    category = "Parameter annotation" and
    parameter_annotation_metrics(totalCount, builtinCount, forwardDeclCount, 
                              simpleTypeCount, complexTypeCount, optionalTypeCount)
  )
  or
  // Return type annotation metrics
  (
    category = "Return type annotation" and
    return_type_annotation_metrics(totalCount, builtinCount, forwardDeclCount, 
                              simpleTypeCount, complexTypeCount, optionalTypeCount)
  )
  or
  // Annotated assignment metrics
  (
    category = "Annotated assignment" and
    assignment_annotation_metrics(totalCount, builtinCount, forwardDeclCount, 
                               simpleTypeCount, complexTypeCount, optionalTypeCount)
  )
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