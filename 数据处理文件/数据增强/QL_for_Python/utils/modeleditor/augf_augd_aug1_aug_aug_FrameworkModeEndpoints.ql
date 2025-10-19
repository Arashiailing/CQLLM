/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies and catalogs all accessible endpoints (methods and attributes) 
 *              within the model editor's framework mode, filtering out test files 
 *              and auto-generated code artifacts from the analysis results.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint modelEditorEndpoint
select 
  modelEditorEndpoint,  // Primary endpoint reference being analyzed
  modelEditorEndpoint.getNamespace(),  // Logical container/namespace for the endpoint
  modelEditorEndpoint.getClass(),  // Class that declares this endpoint
  modelEditorEndpoint.getFunctionName(),  // Unique method or function identifier
  modelEditorEndpoint.getParameters(),  // Complete parameter specification
  modelEditorEndpoint.getSupportedStatus(),  // HTTP status codes supported by endpoint
  modelEditorEndpoint.getFileName(),  // Physical file location in codebase
  modelEditorEndpoint.getSupportedType(),  // Data type compatibility information
  modelEditorEndpoint.getKind()  // Endpoint type classification (method/attribute)