/**
 * @name Model Editor Framework-Mode Endpoint Inventory
 * @description Systematic catalog of accessible endpoints (methods and attributes) 
 *              within the model editor's framework mode. Excludes test files and 
 *              auto-generated artifacts to focus exclusively on production endpoints.
 *              Provides comprehensive visibility into the framework's API surface.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode api-inventory
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  // Primary endpoint reference
  frameworkEndpoint,
  
  // Structural context
  frameworkEndpoint.getNamespace(),  // Namespace hierarchy
  frameworkEndpoint.getClass(),      // Parent class container
  
  // Functional characteristics
  frameworkEndpoint.getFunctionName(),  // Method identifier
  frameworkEndpoint.getParameters(),    // Parameter specification
  frameworkEndpoint.getSupportedStatus(),  // Supported response codes
  
  // Source and typing information
  frameworkEndpoint.getFileName(),      // Source file location
  frameworkEndpoint.getSupportedType(), // Data type definitions
  frameworkEndpoint.getKind()           // Endpoint category