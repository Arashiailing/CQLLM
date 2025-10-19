/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies accessible endpoints (methods/attributes) in the model editor's framework mode.
 *              Excludes test code and generated artifacts from results.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint editorEndpoint
select 
  editorEndpoint,  // Core endpoint reference
  editorEndpoint.getNamespace(),  // Containing namespace
  editorEndpoint.getClass(),  // Defining parent class
  editorEndpoint.getFunctionName(),  // Method/function identifier
  editorEndpoint.getParameters(),  // Parameter signature
  editorEndpoint.getSupportedStatus(),  // Supported HTTP status codes
  editorEndpoint.getFileName(),  // Source file location
  editorEndpoint.getSupportedType(),  // Supported data types
  editorEndpoint.getKind()  // Endpoint classification (method/attribute)