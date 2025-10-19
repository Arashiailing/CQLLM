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
  TFunctionWithReturnAnnotation(FunctionExpr func) { exists(func.getReturns()) } or
  TParameterWithAnnotation(Parameter param) { exists(param.getAnnotation()) } or
  TAssignmentWithAnnotation(AnnAssign assignment) { exists(assignment.getAnnotation()) }

// Abstract base class for elements with type annotations
abstract class AnnotatedElement extends ElementWithTypeAnnotation {
  string toString() { result = "AnnotatedElement" }
  abstract Expr getAnnotation();
}

// Function expressions with return type annotations
class FunctionWithReturnAnnotation extends TFunctionWithReturnAnnotation, AnnotatedElement {
  FunctionExpr functionExpression;

  FunctionWithReturnAnnotation() { this = TFunctionWithReturnAnnotation(functionExpression) }
  override Expr getAnnotation() { result = functionExpression.getReturns() }
}

// Parameters with type annotations
class ParameterWithAnnotation extends TParameterWithAnnotation, AnnotatedElement {
  Parameter parameter;

  ParameterWithAnnotation() { this = TParameterWithAnnotation(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Assignment statements with type annotations
class AssignmentWithAnnotation extends TAssignmentWithAnnotation, AnnotatedElement {
  AnnAssign assignment;

  AssignmentWithAnnotation() { this = TAssignmentWithAnnotation(assignment) }
  override Expr getAnnotation() { result = assignment.getAnnotation() }
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

// Computes metrics for different categories of type annotations
predicate computeAnnotationMetrics(
  string annotationCategory, int totalAnnotations, int builtinTypeAnnotations, 
  int forwardDeclarationAnnotations, int simpleTypeAnnotations, int complexTypeAnnotations, 
  int optionalTypeAnnotations
) {
  // Parameter annotation metrics
  (annotationCategory = "Parameter annotation" and
    totalAnnotations = count(ParameterWithAnnotation param) and
    builtinTypeAnnotations = count(ParameterWithAnnotation param | 
      isBuiltinType(param.getAnnotation())) and
    forwardDeclarationAnnotations = count(ParameterWithAnnotation param | 
      isForwardDeclaration(param.getAnnotation())) and
    simpleTypeAnnotations = count(ParameterWithAnnotation param | 
      isSimpleType(param.getAnnotation())) and
    complexTypeAnnotations = count(ParameterWithAnnotation param | 
      isComplexType(param.getAnnotation())) and
    optionalTypeAnnotations = count(ParameterWithAnnotation param | 
      isOptionalType(param.getAnnotation())))
  or
  // Return type annotation metrics
  (annotationCategory = "Return type annotation" and
    totalAnnotations = count(FunctionWithReturnAnnotation func) and
    builtinTypeAnnotations = count(FunctionWithReturnAnnotation func | 
      isBuiltinType(func.getAnnotation())) and
    forwardDeclarationAnnotations = count(FunctionWithReturnAnnotation func | 
      isForwardDeclaration(func.getAnnotation())) and
    simpleTypeAnnotations = count(FunctionWithReturnAnnotation func | 
      isSimpleType(func.getAnnotation())) and
    complexTypeAnnotations = count(FunctionWithReturnAnnotation func | 
      isComplexType(func.getAnnotation())) and
    optionalTypeAnnotations = count(FunctionWithReturnAnnotation func | 
      isOptionalType(func.getAnnotation())))
  or
  // Annotated assignment metrics
  (annotationCategory = "Annotated assignment" and
    totalAnnotations = count(AssignmentWithAnnotation assign) and
    builtinTypeAnnotations = count(AssignmentWithAnnotation assign | 
      isBuiltinType(assign.getAnnotation())) and
    forwardDeclarationAnnotations = count(AssignmentWithAnnotation assign | 
      isForwardDeclaration(assign.getAnnotation())) and
    simpleTypeAnnotations = count(AssignmentWithAnnotation assign | 
      isSimpleType(assign.getAnnotation())) and
    complexTypeAnnotations = count(AssignmentWithAnnotation assign | 
      isComplexType(assign.getAnnotation())) and
    optionalTypeAnnotations = count(AssignmentWithAnnotation assign | 
      isOptionalType(assign.getAnnotation())))
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