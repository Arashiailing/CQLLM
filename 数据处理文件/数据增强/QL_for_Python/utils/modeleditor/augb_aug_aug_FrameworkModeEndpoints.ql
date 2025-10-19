/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies accessible endpoints in model editor framework mode, 
 *              excluding test code and generated artifacts.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint ep
select 
  ep,                                    // Core endpoint reference
  ep.getNamespace(),                     // Namespace containing the endpoint
  ep.getClass(),                         // Parent class defining the endpoint
  ep.getFunctionName(),                  // Method/function name of the endpoint
  ep.getParameters(),                    // Parameter signature of the endpoint
  ep.getSupportedStatus(),               // Supported HTTP status codes
  ep.getFileName(),                      // Source file containing endpoint definition
  ep.getSupportedType(),                 // Supported data types for the endpoint
  ep.getKind()                           // Endpoint classification (method/attribute)