/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies accessible endpoints in model editor framework mode, 
 *              excluding test code and generated artifacts.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint endpoint
select 
  endpoint,                              // Core endpoint reference
  endpoint.getNamespace(),               // Namespace containing the endpoint
  endpoint.getClass(),                   // Parent class defining the endpoint
  endpoint.getFunctionName(),            // Method/function name of the endpoint
  endpoint.getParameters(),              // Parameter signature of the endpoint
  endpoint.getSupportedStatus(),         // Supported HTTP status codes
  endpoint.getFileName(),                // Source file containing endpoint definition
  endpoint.getSupportedType(),           // Supported data types for the endpoint
  endpoint.getKind()                     // Endpoint classification (method/attribute)