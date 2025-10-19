/**
 * @name Model Editor Framework Endpoint Discovery
 * @description Identifies and catalogs all operational endpoints within the Model Editor's 
 *              framework environment, excluding test implementations and auto-generated code.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint modelEditorEndpoint
select 
  modelEditorEndpoint,                     // Core endpoint reference
  modelEditorEndpoint.getNamespace(),      // Namespace containing the endpoint
  modelEditorEndpoint.getClass(),          // Parent class defining the endpoint
  modelEditorEndpoint.getFunctionName(),   // Method/function name of the endpoint
  modelEditorEndpoint.getParameters(),     // Parameter signature of the endpoint
  modelEditorEndpoint.getSupportedStatus(), // Supported HTTP status codes
  modelEditorEndpoint.getFileName(),       // Source file containing endpoint definition
  modelEditorEndpoint.getSupportedType(),  // Supported data types for the endpoint
  modelEditorEndpoint.getKind()            // Endpoint classification (method/attribute)