/**
 * @name Symbol Definition Navigator
 * @description Advanced query for mapping symbol usages to their corresponding definitions in Python source code.
 *               This facilitates navigation between references and declarations.
 * @kind definitions
 * @id py/jump-to-definition
 */

// Import core Python analysis module for syntactic and semantic analysis
import python

// Import definition tracking utilities for resolving symbol references to their declarations
import analysis.DefinitionTracking

// Main query body: identify symbol references and map them to their definitions
from NiceLocationExpr symbolReference, Definition symbolDeclaration, string declarationType
// Establish the relationship between references and their corresponding declarations
where symbolDeclaration = definitionOf(symbolReference, declarationType)
// Output the reference location, its declaration, and the type of declaration
select symbolReference, symbolDeclaration, declarationType