/**
 * @name Model editor framework endpoint inventory
 * @description Provides a comprehensive inventory of all accessible endpoints (methods and attributes) 
 *              within the model editor's framework operational mode. This query systematically 
 *              filters out test files and auto-generated code to focus on production endpoints.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  frameworkEndpoint,  // Core endpoint entity under analysis
  frameworkEndpoint.getNamespace(),  // Namespace context containing the endpoint
  frameworkEndpoint.getClass(),  // Host class defining the endpoint
  frameworkEndpoint.getFunctionName(),  // Method or function identifier
  frameworkEndpoint.getParameters(),  // Parameter signature details
  frameworkEndpoint.getSupportedStatus(),  // Supported HTTP status codes
  frameworkEndpoint.getFileName(),  // Source file location
  frameworkEndpoint.getSupportedType(),  // Compatible data types
  frameworkEndpoint.getKind()  // Endpoint classification (method/attribute)