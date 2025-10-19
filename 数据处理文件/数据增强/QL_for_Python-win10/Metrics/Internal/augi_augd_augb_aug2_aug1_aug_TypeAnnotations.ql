/**
 * @name Type metrics
 * @description Analyzes Python type annotations across different code elements,
 *              categorizing them by annotation types (parameter, return, assignment)
 *              and complexity levels (built-in, forward-declared, simple, complex, optional).
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types (e.g., int, str, bool)
class PythonBuiltinType extends Name {
  PythonBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype TypeAnnotatableElement =
  TFunctionWithReturnType(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or
  TParameterWithTypeAnnotation(Parameter parameter) { exists(parameter.getAnnotation()) } or
  TAssignmentWithTypeAnnotation(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class TypeAnnotatable extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotatable" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, TypeAnnotatable {
  FunctionExpr functionExpr;

  FunctionWithReturnType() { this = TFunctionWithReturnType(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Parameters with type annotations
class ParameterWithTypeAnnotation extends TParameterWithTypeAnnotation, TypeAnnotatable {
  Parameter parameter;

  ParameterWithTypeAnnotation() { this = TParameterWithTypeAnnotation(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithTypeAnnotation extends TAssignmentWithTypeAnnotation, TypeAnnotatable {
  AnnAssign assignment;

  AssignmentWithTypeAnnotation() { this = TAssignmentWithTypeAnnotation(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
}

// Type classification predicates

/** Holds if `typeAnnotation` is a forward-declared type (string literal). */
predicate is_forward_declaration(Expr typeAnnotation) { typeAnnotation instanceof StringLiteral }

/** Holds if `typeAnnotation` is a complex type that may be difficult to analyze. */
predicate is_complex_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Subscript and not is_optional_type(typeAnnotation)) or
  typeAnnotation instanceof Tuple or
  typeAnnotation instanceof List
}

/** Holds if `typeAnnotation` is an Optional type (e.g., Optional[...]). */
predicate is_optional_type(Subscript typeAnnotation) { typeAnnotation.getObject().(Name).getId() = "Optional" }

/** Holds if `typeAnnotation` is a simple type (non-built-in identifier or attribute chain). */
predicate is_simple_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Name and not typeAnnotation instanceof PythonBuiltinType) or
  is_simple_type(typeAnnotation.(Attribute).getObject())
}

/** Holds if `typeAnnotation` is a built-in type. */
predicate is_builtin_type(Expr typeAnnotation) { typeAnnotation instanceof PythonBuiltinType }

// Helper predicates for counting different types of annotations

predicate count_parameter_annotations(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(ParameterWithTypeAnnotation annotatedElement) and
  builtinTypeAnnotations = count(ParameterWithTypeAnnotation annotatedElement | 
    is_builtin_type(annotatedElement.getAnnotation())) and
  forwardDeclarationAnnotations = count(ParameterWithTypeAnnotation annotatedElement | 
    is_forward_declaration(annotatedElement.getAnnotation())) and
  simpleTypeAnnotations = count(ParameterWithTypeAnnotation annotatedElement | 
    is_simple_type(annotatedElement.getAnnotation())) and
  complexTypeAnnotations = count(ParameterWithTypeAnnotation annotatedElement | 
    is_complex_type(annotatedElement.getAnnotation())) and
  optionalTypeAnnotations = count(ParameterWithTypeAnnotation annotatedElement | 
    is_optional_type(annotatedElement.getAnnotation()))
}

predicate count_return_type_annotations(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(FunctionWithReturnType annotatedElement) and
  builtinTypeAnnotations = count(FunctionWithReturnType annotatedElement | 
    is_builtin_type(annotatedElement.getAnnotation())) and
  forwardDeclarationAnnotations = count(FunctionWithReturnType annotatedElement | 
    is_forward_declaration(annotatedElement.getAnnotation())) and
  simpleTypeAnnotations = count(FunctionWithReturnType annotatedElement | 
    is_simple_type(annotatedElement.getAnnotation())) and
  complexTypeAnnotations = count(FunctionWithReturnType annotatedElement | 
    is_complex_type(annotatedElement.getAnnotation())) and
  optionalTypeAnnotations = count(FunctionWithReturnType annotatedElement | 
    is_optional_type(annotatedElement.getAnnotation()))
}

predicate count_assignment_annotations(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(AssignmentWithTypeAnnotation annotatedElement) and
  builtinTypeAnnotations = count(AssignmentWithTypeAnnotation annotatedElement | 
    is_builtin_type(annotatedElement.getAnnotation())) and
  forwardDeclarationAnnotations = count(AssignmentWithTypeAnnotation annotatedElement | 
    is_forward_declaration(annotatedElement.getAnnotation())) and
  simpleTypeAnnotations = count(AssignmentWithTypeAnnotation annotatedElement | 
    is_simple_type(annotatedElement.getAnnotation())) and
  complexTypeAnnotations = count(AssignmentWithTypeAnnotation annotatedElement | 
    is_complex_type(annotatedElement.getAnnotation())) and
  optionalTypeAnnotations = count(AssignmentWithTypeAnnotation annotatedElement | 
    is_optional_type(annotatedElement.getAnnotation()))
}

// Computes metrics for different categories of type annotations
predicate type_annotation_metrics(
  string annotationCategory, int totalAnnotations, int builtinTypeAnnotations, 
  int forwardDeclarationAnnotations, int simpleTypeAnnotations, int complexTypeAnnotations, 
  int optionalTypeAnnotations
) {
  // Parameter annotation metrics
  (annotationCategory = "Parameter annotation" and
   count_parameter_annotations(totalAnnotations, builtinTypeAnnotations, 
                              forwardDeclarationAnnotations, simpleTypeAnnotations, 
                              complexTypeAnnotations, optionalTypeAnnotations))
  or
  // Return type annotation metrics
  (annotationCategory = "Return type annotation" and
   count_return_type_annotations(totalAnnotations, builtinTypeAnnotations, 
                                forwardDeclarationAnnotations, simpleTypeAnnotations, 
                                complexTypeAnnotations, optionalTypeAnnotations))
  or
  // Annotated assignment metrics
  (annotationCategory = "Annotated assignment" and
   count_assignment_annotations(totalAnnotations, builtinTypeAnnotations, 
                               forwardDeclarationAnnotations, simpleTypeAnnotations, 
                               complexTypeAnnotations, optionalTypeAnnotations))
}

// Query execution and results output
from 
  string annotationCategory, int totalAnnotations, int builtinTypeAnnotations, 
  int forwardDeclarationAnnotations, int simpleTypeAnnotations, int complexTypeAnnotations, 
  int optionalTypeAnnotations
where 
  type_annotation_metrics(annotationCategory, totalAnnotations, builtinTypeAnnotations, 
                         forwardDeclarationAnnotations, simpleTypeAnnotations, 
                         complexTypeAnnotations, optionalTypeAnnotations)
select 
  annotationCategory, totalAnnotations, builtinTypeAnnotations, forwardDeclarationAnnotations, 
  simpleTypeAnnotations, complexTypeAnnotations, optionalTypeAnnotations