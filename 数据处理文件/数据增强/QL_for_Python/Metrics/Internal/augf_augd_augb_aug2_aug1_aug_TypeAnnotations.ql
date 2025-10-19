/**
 * @name Type metrics
 * @description Analyzes and categorizes type annotations in Python code, providing metrics
 *              on parameter annotations, return types, and annotated assignments.
 * @kind table
 * @id py/type-metrics
 */

import python

// Represents Python built-in types (e.g., int, str, bool)
class BuiltinPythonType extends Name {
  BuiltinPythonType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements that can have type annotations
newtype ElementWithTypeAnnotation =
  TFunctionWithReturnAnnotation(FunctionExpr funcExpr) { exists(funcExpr.getReturns()) } or
  TParameterWithAnnotation(Parameter param) { exists(param.getAnnotation()) } or
  TAssignmentWithAnnotation(AnnAssign assign) { exists(assign.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class AnnotatedElement extends ElementWithTypeAnnotation {
  string toString() { result = "AnnotatedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnAnnotation extends TFunctionWithReturnAnnotation, AnnotatedElement {
  FunctionExpr funcExpr;

  FunctionWithReturnAnnotation() { this = TFunctionWithReturnAnnotation(funcExpr) }
  override Expr getAnnotation() { result = funcExpr.getReturns() }
}

// Parameters with type annotations
class ParameterWithAnnotation extends TParameterWithAnnotation, AnnotatedElement {
  Parameter param;

  ParameterWithAnnotation() { this = TParameterWithAnnotation(param) }
  override Expr getAnnotation() { result = param.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithAnnotation extends TAssignmentWithAnnotation, AnnotatedElement {
  AnnAssign assign;

  AssignmentWithAnnotation() { this = TAssignmentWithAnnotation(assign) }
  override Expr getAnnotation() { result = assign.getAnnotation() }
}

// Type classification predicates

/** Holds if `typeAnnotation` is a forward-declared type (string literal). */
predicate isForwardDeclaration(Expr typeAnnotation) { typeAnnotation instanceof StringLiteral }

/** Holds if `typeAnnotation` is a complex type that may be difficult to analyze. */
predicate isComplexType(Expr typeAnnotation) {
  (typeAnnotation instanceof Subscript and not isOptionalType(typeAnnotation)) or
  typeAnnotation instanceof Tuple or
  typeAnnotation instanceof List
}

/** Holds if `typeAnnotation` is an Optional type (e.g., Optional[...]). */
predicate isOptionalType(Subscript typeAnnotation) { typeAnnotation.getObject().(Name).getId() = "Optional" }

/** Holds if `typeAnnotation` is a simple type (non-built-in identifier or attribute chain). */
predicate isSimpleType(Expr typeAnnotation) {
  (typeAnnotation instanceof Name and not typeAnnotation instanceof BuiltinPythonType) or
  isSimpleType(typeAnnotation.(Attribute).getObject())
}

/** Holds if `typeAnnotation` is a built-in type. */
predicate isBuiltinType(Expr typeAnnotation) { typeAnnotation instanceof BuiltinPythonType }

// Helper predicates for counting different types of annotations

predicate computeParameterAnnotationMetrics(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(ParameterWithAnnotation parameterWithAnnotation) and
  builtinTypeAnnotations = count(ParameterWithAnnotation parameterWithAnnotation | 
    isBuiltinType(parameterWithAnnotation.getAnnotation())) and
  forwardDeclarationAnnotations = count(ParameterWithAnnotation parameterWithAnnotation | 
    isForwardDeclaration(parameterWithAnnotation.getAnnotation())) and
  simpleTypeAnnotations = count(ParameterWithAnnotation parameterWithAnnotation | 
    isSimpleType(parameterWithAnnotation.getAnnotation())) and
  complexTypeAnnotations = count(ParameterWithAnnotation parameterWithAnnotation | 
    isComplexType(parameterWithAnnotation.getAnnotation())) and
  optionalTypeAnnotations = count(ParameterWithAnnotation parameterWithAnnotation | 
    isOptionalType(parameterWithAnnotation.getAnnotation()))
}

predicate computeReturnAnnotationMetrics(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(FunctionWithReturnAnnotation functionWithAnnotation) and
  builtinTypeAnnotations = count(FunctionWithReturnAnnotation functionWithAnnotation | 
    isBuiltinType(functionWithAnnotation.getAnnotation())) and
  forwardDeclarationAnnotations = count(FunctionWithReturnAnnotation functionWithAnnotation | 
    isForwardDeclaration(functionWithAnnotation.getAnnotation())) and
  simpleTypeAnnotations = count(FunctionWithReturnAnnotation functionWithAnnotation | 
    isSimpleType(functionWithAnnotation.getAnnotation())) and
  complexTypeAnnotations = count(FunctionWithReturnAnnotation functionWithAnnotation | 
    isComplexType(functionWithAnnotation.getAnnotation())) and
  optionalTypeAnnotations = count(FunctionWithReturnAnnotation functionWithAnnotation | 
    isOptionalType(functionWithAnnotation.getAnnotation()))
}

predicate computeAssignmentAnnotationMetrics(
  int totalAnnotations, int builtinTypeAnnotations, int forwardDeclarationAnnotations, 
  int simpleTypeAnnotations, int complexTypeAnnotations, int optionalTypeAnnotations
) {
  totalAnnotations = count(AssignmentWithAnnotation assignmentWithAnnotation) and
  builtinTypeAnnotations = count(AssignmentWithAnnotation assignmentWithAnnotation | 
    isBuiltinType(assignmentWithAnnotation.getAnnotation())) and
  forwardDeclarationAnnotations = count(AssignmentWithAnnotation assignmentWithAnnotation | 
    isForwardDeclaration(assignmentWithAnnotation.getAnnotation())) and
  simpleTypeAnnotations = count(AssignmentWithAnnotation assignmentWithAnnotation | 
    isSimpleType(assignmentWithAnnotation.getAnnotation())) and
  complexTypeAnnotations = count(AssignmentWithAnnotation assignmentWithAnnotation | 
    isComplexType(assignmentWithAnnotation.getAnnotation())) and
  optionalTypeAnnotations = count(AssignmentWithAnnotation assignmentWithAnnotation | 
    isOptionalType(assignmentWithAnnotation.getAnnotation()))
}

// Computes metrics for different categories of type annotations
predicate computeAnnotationMetrics(
  string annotationCategory, int totalAnnotations, int builtinTypeAnnotations, 
  int forwardDeclarationAnnotations, int simpleTypeAnnotations, int complexTypeAnnotations, 
  int optionalTypeAnnotations
) {
  // Parameter annotation metrics
  (annotationCategory = "Parameter annotation" and
   computeParameterAnnotationMetrics(totalAnnotations, builtinTypeAnnotations, 
                                    forwardDeclarationAnnotations, simpleTypeAnnotations, 
                                    complexTypeAnnotations, optionalTypeAnnotations))
  or
  // Return type annotation metrics
  (annotationCategory = "Return type annotation" and
   computeReturnAnnotationMetrics(totalAnnotations, builtinTypeAnnotations, 
                                 forwardDeclarationAnnotations, simpleTypeAnnotations, 
                                 complexTypeAnnotations, optionalTypeAnnotations))
  or
  // Annotated assignment metrics
  (annotationCategory = "Annotated assignment" and
   computeAssignmentAnnotationMetrics(totalAnnotations, builtinTypeAnnotations, 
                                     forwardDeclarationAnnotations, simpleTypeAnnotations, 
                                     complexTypeAnnotations, optionalTypeAnnotations))
}

// Query execution and results output
from 
  string annotationCategory, int totalAnnotations, int builtinTypeAnnotations, 
  int forwardDeclarationAnnotations, int simpleTypeAnnotations, int complexTypeAnnotations, 
  int optionalTypeAnnotations
where 
  computeAnnotationMetrics(annotationCategory, totalAnnotations, builtinTypeAnnotations, 
                          forwardDeclarationAnnotations, simpleTypeAnnotations, 
                          complexTypeAnnotations, optionalTypeAnnotations)
select 
  annotationCategory, totalAnnotations, builtinTypeAnnotations, forwardDeclarationAnnotations, 
  simpleTypeAnnotations, complexTypeAnnotations, optionalTypeAnnotations