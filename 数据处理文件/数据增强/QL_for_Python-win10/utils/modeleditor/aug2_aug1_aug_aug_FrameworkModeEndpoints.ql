/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Catalogs accessible endpoints (methods/attributes) in the model editor's 
 *              framework mode, excluding test code and generated artifacts from results.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  frameworkEndpoint,  // Primary endpoint object
  frameworkEndpoint.getNamespace(),  // Namespace containing the endpoint
  frameworkEndpoint.getClass(),  // Parent class defining the endpoint
  frameworkEndpoint.getFunctionName(),  // Method/function identifier
  frameworkEndpoint.getParameters(),  // Parameter signature details
  frameworkEndpoint.getSupportedStatus(),  // Supported HTTP status codes
  frameworkEndpoint.getFileName(),  // Source file location
  frameworkEndpoint.getSupportedType(),  // Supported data types
  frameworkEndpoint.getKind()  // Endpoint classification (method/attribute)