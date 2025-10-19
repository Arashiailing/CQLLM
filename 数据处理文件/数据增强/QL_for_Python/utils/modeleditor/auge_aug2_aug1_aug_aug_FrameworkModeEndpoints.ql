/**
 * @name Model editor framework endpoint inventory
 * @description Identifies and lists all accessible endpoints (methods and attributes) 
 *              within the model editor's framework operational mode, filtering out 
 *              test files and auto-generated code from the results.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint modelEditorEndpoint
select 
  modelEditorEndpoint,  // The primary endpoint entity being analyzed
  modelEditorEndpoint.getNamespace(),  // Namespace context where the endpoint resides
  modelEditorEndpoint.getClass(),  // Class that contains the endpoint definition
  modelEditorEndpoint.getFunctionName(),  // Identifier for the method or function
  modelEditorEndpoint.getParameters(),  // Detailed parameter signature of the endpoint
  modelEditorEndpoint.getSupportedStatus(),  // HTTP status codes supported by the endpoint
  modelEditorEndpoint.getFileName(),  // Source file path where the endpoint is defined
  modelEditorEndpoint.getSupportedType(),  // Data types that the endpoint can handle
  modelEditorEndpoint.getKind()  // Categorization of the endpoint (method or attribute)