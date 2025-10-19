/**
 * @name Model Editor Framework-Mode Endpoint Inventory
 * @description Comprehensive inventory of all accessible endpoints (methods and attributes) 
 *              within the model editor's framework mode. This query systematically excludes 
 *              test files and auto-generated code artifacts to focus on production endpoints.
 *              The results provide a detailed view of the framework's API surface area.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode api-inventory
 */

import modeling.ModelEditor

from Endpoint editorEndpoint
select 
  // Core endpoint reference
  editorEndpoint,  
  
  // Structural hierarchy
  editorEndpoint.getNamespace(),  // Namespace context
  editorEndpoint.getClass(),      // Parent class definition
  
  // Functional signature
  editorEndpoint.getFunctionName(),  // Method identifier
  editorEndpoint.getParameters(),    // Parameter signature
  editorEndpoint.getSupportedStatus(),  // HTTP response codes
  
  // Location and typing
  editorEndpoint.getFileName(),      // Source file location
  editorEndpoint.getSupportedType(), // Data type specifications
  editorEndpoint.getKind()           // Endpoint classification