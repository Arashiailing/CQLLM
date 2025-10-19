/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Catalogs all accessible endpoints (both methods and attributes) within the 
 *              model editor's framework mode. This analysis excludes test files and generated 
 *              code artifacts to focus solely on production endpoints.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor module providing endpoint analysis functionality
import modeling.ModelEditor

// Source all framework-mode endpoints from the ModelEditor system
from Endpoint frameworkEndpoint
select 
  // Primary endpoint reference
  frameworkEndpoint,
  // Namespace where the endpoint is defined
  frameworkEndpoint.getNamespace(),
  // Class that contains the endpoint definition
  frameworkEndpoint.getClass(),
  // Name of the method/function representing the endpoint
  frameworkEndpoint.getFunctionName(),
  // Parameter signature defining the endpoint interface
  frameworkEndpoint.getParameters(),
  // HTTP status codes supported by this endpoint
  frameworkEndpoint.getSupportedStatus(),
  // Source file path where endpoint is implemented
  frameworkEndpoint.getFileName(),
  // Data types that the endpoint can process
  frameworkEndpoint.getSupportedType(),
  // Endpoint categorization (method or attribute)
  frameworkEndpoint.getKind()