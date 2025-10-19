/**
 * @name Type metrics
 * @description Quantifies different categories of type annotations in Python code
 * @kind table
 * @id py/type-metrics
 */

import python

// Core Python built-in types for type annotation analysis
class CoreBuiltinType extends Name {
  CoreBuiltinType() { this.getId() in ["int", "float", "str", "bool", "bytes", "None"] }
}

// Union type for elements supporting type annotations
newtype TypeAnnotatableElement =
  TFunctionWithReturnType(FunctionExpr functionExpr) { exists(functionExpr.getReturns()) } or 
  TParameterWithTypeAnnotation(Parameter parameter) { exists(parameter.getAnnotation()) } or 
  TAssignmentWithTypeAnnotation(AnnAssign annotatedAssignment) { exists(annotatedAssignment.getAnnotation()) }

// Base class for elements that can have type annotations
abstract class BaseAnnotatable extends TypeAnnotatableElement {
  string toString() { result = "BaseAnnotatable" }
  abstract Expr getAnnotation();
}

// Represents functions with return type annotations
class FunctionWithReturnType extends TFunctionWithReturnType, BaseAnnotatable {
  FunctionExpr functionExpr;
  FunctionWithReturnType() { this = TFunctionWithReturnType(functionExpr) }
  override Expr getAnnotation() { result = functionExpr.getReturns() }
}

// Represents parameters with type annotations
class ParameterWithTypeAnnotation extends TParameterWithTypeAnnotation, BaseAnnotatable {
  Parameter parameter;
  ParameterWithTypeAnnotation() { this = TParameterWithTypeAnnotation(parameter) }
  override Expr getAnnotation() { result = parameter.getAnnotation() }
}

// Represents assignments with type annotations
class AssignmentWithTypeAnnotation extends TAssignmentWithTypeAnnotation, BaseAnnotatable {
  AnnAssign annotatedAssignment;
  AssignmentWithTypeAnnotation() { this = TAssignmentWithTypeAnnotation(annotatedAssignment) }
  override Expr getAnnotation() { result = annotatedAssignment.getAnnotation() }
}

// Type classification predicates
/** Identifies forward-declared types (string literals) */
predicate is_forward_declaration(Expr typeAnnotation) { 
  typeAnnotation instanceof StringLiteral 
}

/** Identifies complex type structures */
predicate is_complex_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Subscript and not is_optional_type(typeAnnotation))
  or
  typeAnnotation instanceof Tuple
  or
  typeAnnotation instanceof List
}

/** Identifies Optional types */
predicate is_optional_type(Subscript typeAnnotation) { 
  typeAnnotation.getObject().(Name).getId() = "Optional" 
}

/** Identifies simple user-defined types */
predicate is_simple_type(Expr typeAnnotation) {
  (typeAnnotation instanceof Name and not typeAnnotation instanceof CoreBuiltinType)
  or
  is_simple_type(typeAnnotation.(Attribute).getObject())
}

/** Identifies built-in types */
predicate is_builtin_type(Expr typeAnnotation) { 
  typeAnnotation instanceof CoreBuiltinType 
}

// Computes type annotation metrics for different annotation categories
predicate type_count(
  string annotationCategory, int totalAnnotations, int builtinTypeCount, int forwardDeclarationCount, 
  int simpleUserTypeCount, int complexTypeStructureCount, int optionalTypeCount
) {
  // Parameter annotation metrics
  annotationCategory = "Parameter annotation" and
  totalAnnotations = count(ParameterWithTypeAnnotation annotatedParameter) and
  builtinTypeCount = count(ParameterWithTypeAnnotation annotatedParameter | is_builtin_type(annotatedParameter.getAnnotation())) and
  forwardDeclarationCount = count(ParameterWithTypeAnnotation annotatedParameter | is_forward_declaration(annotatedParameter.getAnnotation())) and
  simpleUserTypeCount = count(ParameterWithTypeAnnotation annotatedParameter | is_simple_type(annotatedParameter.getAnnotation())) and
  complexTypeStructureCount = count(ParameterWithTypeAnnotation annotatedParameter | is_complex_type(annotatedParameter.getAnnotation())) and
  optionalTypeCount = count(ParameterWithTypeAnnotation annotatedParameter | is_optional_type(annotatedParameter.getAnnotation()))
  or
  // Return type annotation metrics
  annotationCategory = "Return type annotation" and
  totalAnnotations = count(FunctionWithReturnType annotatedFunction) and
  builtinTypeCount = count(FunctionWithReturnType annotatedFunction | is_builtin_type(annotatedFunction.getAnnotation())) and
  forwardDeclarationCount = count(FunctionWithReturnType annotatedFunction | is_forward_declaration(annotatedFunction.getAnnotation())) and
  simpleUserTypeCount = count(FunctionWithReturnType annotatedFunction | is_simple_type(annotatedFunction.getAnnotation())) and
  complexTypeStructureCount = count(FunctionWithReturnType annotatedFunction | is_complex_type(annotatedFunction.getAnnotation())) and
  optionalTypeCount = count(FunctionWithReturnType annotatedFunction | is_optional_type(annotatedFunction.getAnnotation()))
  or
  // Annotated assignment metrics
  annotationCategory = "Annotated assignment" and
  totalAnnotations = count(AssignmentWithTypeAnnotation annotatedAssignmentExpr) and
  builtinTypeCount = count(AssignmentWithTypeAnnotation annotatedAssignmentExpr | is_builtin_type(annotatedAssignmentExpr.getAnnotation())) and
  forwardDeclarationCount = count(AssignmentWithTypeAnnotation annotatedAssignmentExpr | is_forward_declaration(annotatedAssignmentExpr.getAnnotation())) and
  simpleUserTypeCount = count(AssignmentWithTypeAnnotation annotatedAssignmentExpr | is_simple_type(annotatedAssignmentExpr.getAnnotation())) and
  complexTypeStructureCount = count(AssignmentWithTypeAnnotation annotatedAssignmentExpr | is_complex_type(annotatedAssignmentExpr.getAnnotation())) and
  optionalTypeCount = count(AssignmentWithTypeAnnotation annotatedAssignmentExpr | is_optional_type(annotatedAssignmentExpr.getAnnotation()))
}

// Query execution and result projection
from
  string annotationCategory, int totalAnnotations, int builtinTypeCount, int forwardDeclarationCount, 
  int simpleUserTypeCount, int complexTypeStructureCount, int optionalTypeCount
where 
  type_count(annotationCategory, totalAnnotations, builtinTypeCount, forwardDeclarationCount, simpleUserTypeCount, complexTypeStructureCount, optionalTypeCount)
select 
  annotationCategory, totalAnnotations, builtinTypeCount, forwardDeclarationCount, 
  simpleUserTypeCount, complexTypeStructureCount, optionalTypeCount