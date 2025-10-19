/**
 * @name Model Editor Framework Endpoint Discovery
 * @description Catalogs all discoverable endpoints operating within the Model Editor's framework mode,
 *              systematically filtering out test implementations and auto-generated code artifacts.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  frameworkEndpoint,                     // Core endpoint reference
  frameworkEndpoint.getNamespace(),      // Namespace containing the endpoint
  frameworkEndpoint.getClass(),          // Parent class defining the endpoint
  frameworkEndpoint.getFunctionName(),   // Method/function name of the endpoint
  frameworkEndpoint.getParameters(),     // Parameter signature of the endpoint
  frameworkEndpoint.getSupportedStatus(), // Supported HTTP status codes
  frameworkEndpoint.getFileName(),       // Source file containing endpoint definition
  frameworkEndpoint.getSupportedType(),  // Supported data types for the endpoint
  frameworkEndpoint.getKind()            // Endpoint classification (method/attribute)