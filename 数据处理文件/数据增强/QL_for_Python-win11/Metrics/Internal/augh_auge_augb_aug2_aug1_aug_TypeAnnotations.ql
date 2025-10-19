/**
 * @name Type metrics
 * @description Analyzes and quantifies different categories of type annotations in Python code,
 *              including parameter annotations, return types, and annotated assignments.
 *              This query provides metrics on built-in types, forward declarations,
 *              simple types, complex types, and optional types.
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
  TTypeAnnotatableFunctionElement(FunctionExpr func) { exists(func.getReturns()) } or
  TTypeAnnotatableParameterElement(Parameter param) { exists(param.getAnnotation()) } or
  TTypeAnnotatableAssignmentElement(AnnAssign assign) { exists(assign.getAnnotation()) }

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

/** Holds if `annotationExpr` is a forward-declared type (string literal). */
predicate is_forward_declaration(Expr annotationExpr) { annotationExpr instanceof StringLiteral }

/** Holds if `annotationExpr` is a complex type that may be difficult to analyze. */
predicate is_complex_type(Expr annotationExpr) {
  (annotationExpr instanceof Subscript and not is_optional_type(annotationExpr)) or
  annotationExpr instanceof Tuple or
  annotationExpr instanceof List
}

/** Holds if `annotationExpr` is an Optional type (e.g., Optional[...]). */
predicate is_optional_type(Subscript annotationExpr) { annotationExpr.getObject().(Name).getId() = "Optional" }

/** Holds if `annotationExpr` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr annotationExpr) {
  (annotationExpr instanceof Name and not annotationExpr instanceof BuiltinType) or
  is_simple_type(annotationExpr.(Attribute).getObject())
}

/** Holds if `annotationExpr` is a built-in type. */
predicate is_builtin_type(Expr annotationExpr) { annotationExpr instanceof BuiltinType }

// Computes metrics for parameter type annotations
predicate parameter_annotation_metrics(
  int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  totalCount = count(ParameterTypeAnnotationElement annotatedParam) and
  builtinCount = count(ParameterTypeAnnotationElement annotatedParam | is_builtin_type(annotatedParam.getAnnotation())) and
  forwardDeclCount = count(ParameterTypeAnnotationElement annotatedParam | is_forward_declaration(annotatedParam.getAnnotation())) and
  simpleTypeCount = count(ParameterTypeAnnotationElement annotatedParam | is_simple_type(annotatedParam.getAnnotation())) and
  complexTypeCount = count(ParameterTypeAnnotationElement annotatedParam | is_complex_type(annotatedParam.getAnnotation())) and
  optionalTypeCount = count(ParameterTypeAnnotationElement annotatedParam | is_optional_type(annotatedParam.getAnnotation()))
}

// Computes metrics for return type annotations
predicate return_type_annotation_metrics(
  int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  totalCount = count(FunctionTypeAnnotationElement annotatedFunc) and
  builtinCount = count(FunctionTypeAnnotationElement annotatedFunc | is_builtin_type(annotatedFunc.getAnnotation())) and
  forwardDeclCount = count(FunctionTypeAnnotationElement annotatedFunc | is_forward_declaration(annotatedFunc.getAnnotation())) and
  simpleTypeCount = count(FunctionTypeAnnotationElement annotatedFunc | is_simple_type(annotatedFunc.getAnnotation())) and
  complexTypeCount = count(FunctionTypeAnnotationElement annotatedFunc | is_complex_type(annotatedFunc.getAnnotation())) and
  optionalTypeCount = count(FunctionTypeAnnotationElement annotatedFunc | is_optional_type(annotatedFunc.getAnnotation()))
}

// Computes metrics for annotated assignments
predicate assignment_annotation_metrics(
  int totalCount, int builtinCount, int forwardDeclCount, 
  int simpleTypeCount, int complexTypeCount, int optionalTypeCount
) {
  totalCount = count(AssignmentTypeAnnotationElement annotatedAssign) and
  builtinCount = count(AssignmentTypeAnnotationElement annotatedAssign | is_builtin_type(annotatedAssign.getAnnotation())) and
  forwardDeclCount = count(AssignmentTypeAnnotationElement annotatedAssign | is_forward_declaration(annotatedAssign.getAnnotation())) and
  simpleTypeCount = count(AssignmentTypeAnnotationElement annotatedAssign | is_simple_type(annotatedAssign.getAnnotation())) and
  complexTypeCount = count(AssignmentTypeAnnotationElement annotatedAssign | is_complex_type(annotatedAssign.getAnnotation())) and
  optionalTypeCount = count(AssignmentTypeAnnotationElement annotatedAssign | is_optional_type(annotatedAssign.getAnnotation()))
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