/**
 * @name Type metrics
 * @description Provides metrics on type annotations in Python code, categorizing them
 *              by parameter annotations, return types, and annotated assignments.
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
  TFunctionWithReturnType(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or
  TParameterWithTypeAnnotation(Parameter param) { exists(param.getAnnotation()) } or
  TAssignmentWithTypeAnnotation(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class TypeAnnotatable extends TypeAnnotatableElement {
  string toString() { result = "TypeAnnotatable" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, TypeAnnotatable {
  FunctionExpr funcExpr;

  FunctionWithReturnType() { this = TFunctionWithReturnType(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Parameters with type annotations
class ParameterWithTypeAnnotation extends TParameterWithTypeAnnotation, TypeAnnotatable {
  Parameter param;

  ParameterWithTypeAnnotation() { this = TParameterWithTypeAnnotation(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithTypeAnnotation extends TAssignmentWithTypeAnnotation, TypeAnnotatable {
  AnnAssign assign;

  AssignmentWithTypeAnnotation() { this = TAssignmentWithTypeAnnotation(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
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
  totalAnnotations = count(ParameterWithTypeAnnotation parameterWithAnnotation) and
  builtinTypeAnnotations = count(ParameterWithTypeAnnotation parameterWithAnnotation | 
    is_builtin_type(parameterWithAnnotation.getAnnotation())) and
  forwardDeclarationAnnotations = count(ParameterWithTypeAnnotation parameterWithAnnotation | 
    is_forward_declaration(parameterWithAnnotation.getAnnotation())) and
  simpleTypeAnnotations = count(ParameterWithTypeAnnotation parameterWithAnnotation | 
    is_simple_type(parameterWithAnnotation.getAnnotation())) and
  complexTypeAnnotations = count(ParameterWithTypeAnnotation parameterWithAnnotation | 
    is_complex_type(parameterWithAnnotation.getAnnotation())) and
  optionalTypeAnnotations = count(ParameterWithTypeAnnotation parameterWithAnnotation | 
    is_optional_type(parameterWithAnnotation.getAnnotation()))
}

predicate count_return_type_annotations(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(FunctionWithReturnType functionWithAnnotation) and
  builtinTypeAnnotations = count(FunctionWithReturnType functionWithAnnotation | 
    is_builtin_type(functionWithAnnotation.getAnnotation())) and
  forwardDeclarationAnnotations = count(FunctionWithReturnType functionWithAnnotation | 
    is_forward_declaration(functionWithAnnotation.getAnnotation())) and
  simpleTypeAnnotations = count(FunctionWithReturnType functionWithAnnotation | 
    is_simple_type(functionWithAnnotation.getAnnotation())) and
  complexTypeAnnotations = count(FunctionWithReturnType functionWithAnnotation | 
    is_complex_type(functionWithAnnotation.getAnnotation())) and
  optionalTypeAnnotations = count(FunctionWithReturnType functionWithAnnotation | 
    is_optional_type(functionWithAnnotation.getAnnotation()))
}

predicate count_assignment_annotations(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(AssignmentWithTypeAnnotation assignmentWithAnnotation) and
  builtinTypeAnnotations = count(AssignmentWithTypeAnnotation assignmentWithAnnotation | 
    is_builtin_type(assignmentWithAnnotation.getAnnotation())) and
  forwardDeclarationAnnotations = count(AssignmentWithTypeAnnotation assignmentWithAnnotation | 
    is_forward_declaration(assignmentWithAnnotation.getAnnotation())) and
  simpleTypeAnnotations = count(AssignmentWithTypeAnnotation assignmentWithAnnotation | 
    is_simple_type(assignmentWithAnnotation.getAnnotation())) and
  complexTypeAnnotations = count(AssignmentWithTypeAnnotation assignmentWithAnnotation | 
    is_complex_type(assignmentWithAnnotation.getAnnotation())) and
  optionalTypeAnnotations = count(AssignmentWithTypeAnnotation assignmentWithAnnotation | 
    is_optional_type(assignmentWithAnnotation.getAnnotation()))
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