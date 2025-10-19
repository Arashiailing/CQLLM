/**
 * @name Model Editor Framework Endpoint Inventory
 * @description Identifies and catalogs all accessible endpoints (both methods and attributes) 
 *              available in the model editor's framework mode. Excludes test files and 
 *              generated code to focus solely on production endpoints.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor module to leverage endpoint analysis functionality
import modeling.ModelEditor

// Retrieve endpoint data from the ModelEditor framework
from Endpoint editorFrameworkEndpoint
select 
  // Core endpoint reference
  editorFrameworkEndpoint,
  // Namespace that contains the endpoint
  editorFrameworkEndpoint.getNamespace(),
  // Class that defines the endpoint
  editorFrameworkEndpoint.getClass(),
  // Function/method name of the endpoint
  editorFrameworkEndpoint.getFunctionName(),
  // Parameter signature for the endpoint
  editorFrameworkEndpoint.getParameters(),
  // HTTP status codes supported by the endpoint
  editorFrameworkEndpoint.getSupportedStatus(),
  // Source file where endpoint is defined
  editorFrameworkEndpoint.getFileName(),
  // Data types supported by the endpoint
  editorFrameworkEndpoint.getSupportedType(),
  // Endpoint type classification (method or attribute)
  editorFrameworkEndpoint.getKind()