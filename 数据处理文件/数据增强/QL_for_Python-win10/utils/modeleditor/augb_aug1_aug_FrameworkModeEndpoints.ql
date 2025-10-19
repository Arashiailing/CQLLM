/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies all accessible endpoints (methods and attributes) in the model editor's 
 *              framework mode. Excludes test code and generated artifacts to focus on production 
 *              endpoints only.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor module for endpoint analysis capabilities
import modeling.ModelEditor

// Retrieve framework-mode endpoints from ModelEditor
from Endpoint editorEndpoint
select 
  // Core endpoint reference
  editorEndpoint,
  // Namespace containing the endpoint
  editorEndpoint.getNamespace(),
  // Parent class defining the endpoint
  editorEndpoint.getClass(),
  // Method/function name of the endpoint
  editorEndpoint.getFunctionName(),
  // Parameter signature of the endpoint
  editorEndpoint.getParameters(),
  // Supported HTTP status codes
  editorEndpoint.getSupportedStatus(),
  // Source file containing endpoint definition
  editorEndpoint.getFileName(),
  // Supported data types for the endpoint
  editorEndpoint.getSupportedType(),
  // Endpoint classification (method/attribute)
  editorEndpoint.getKind()