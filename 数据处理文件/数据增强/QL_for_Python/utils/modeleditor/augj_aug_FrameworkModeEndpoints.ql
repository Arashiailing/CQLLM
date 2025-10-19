/**
 * @name Catalog of framework-mode endpoints in model editor
 * @description Discovers and lists all accessible endpoints (both methods and attributes) 
 *              that are available within the framework mode of the model editor.
 *              Results exclude test files and auto-generated code components.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor functionality for endpoint discovery
import modeling.ModelEditor

// Extract endpoint information using descriptive variable naming
from Endpoint frameworkEndpoint
select 
  // Primary endpoint reference
  frameworkEndpoint,
  // Namespace where the endpoint is defined
  frameworkEndpoint.getNamespace(),
  // Class that contains the endpoint
  frameworkEndpoint.getClass(),
  // Name of the method or function
  frameworkEndpoint.getFunctionName(),
  // Parameter list for the endpoint
  frameworkEndpoint.getParameters(),
  // HTTP status codes supported by the endpoint
  frameworkEndpoint.getSupportedStatus(),
  // Source file location of the endpoint
  frameworkEndpoint.getFileName(),
  // Data types supported by the endpoint
  frameworkEndpoint.getSupportedType(),
  // Endpoint type classification (method or attribute)
  frameworkEndpoint.getKind()