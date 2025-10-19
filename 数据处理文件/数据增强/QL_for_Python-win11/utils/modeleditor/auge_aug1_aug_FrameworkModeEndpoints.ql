/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies and catalogs all accessible endpoints (both methods and attributes) 
 *              within the model editor's framework mode. This analysis specifically excludes 
 *              test code and auto-generated artifacts to ensure focus on production-level endpoints.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import the ModelEditor module to leverage endpoint analysis capabilities
import modeling.ModelEditor

// Retrieve endpoint data from the ModelEditor framework implementation
from Endpoint modelEditorEndpoint
select 
  // Primary endpoint reference object
  modelEditorEndpoint,
  // Namespace hierarchy where the endpoint is defined
  modelEditorEndpoint.getNamespace(),
  // Parent class that declares the endpoint
  modelEditorEndpoint.getClass(),
  // Name of the method or function representing the endpoint
  modelEditorEndpoint.getFunctionName(),
  // Parameter signature and types accepted by the endpoint
  modelEditorEndpoint.getParameters(),
  // HTTP status codes supported by this endpoint
  modelEditorEndpoint.getSupportedStatus(),
  // Source file path containing the endpoint implementation
  modelEditorEndpoint.getFileName(),
  // Data types that the endpoint can process or return
  modelEditorEndpoint.getSupportedType(),
  // Categorization of endpoint as either method or attribute
  modelEditorEndpoint.getKind()