/**
 * @name Fetch endpoints for use in the model editor (framework mode)
 * @description A list of endpoints accessible (methods and attributes) for consumers of the library. Excludes test and generated code.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor module for model editing capabilities
import modeling.ModelEditor

// Retrieve endpoint information from the Endpoint class
from Endpoint frameworkEndpoint
select 
  // Core endpoint object reference
  frameworkEndpoint,
  // Namespace hierarchy containing the endpoint
  frameworkEndpoint.getNamespace(),
  // Parent class defining the endpoint
  frameworkEndpoint.getClass(),
  // Function/method name of the endpoint
  frameworkEndpoint.getFunctionName(),
  // Parameter specifications for the endpoint
  frameworkEndpoint.getParameters(),
  // HTTP status codes supported by the endpoint
  frameworkEndpoint.getSupportedStatus(),
  // Source file containing the endpoint definition
  frameworkEndpoint.getFileName(),
  // Data types supported by the endpoint
  frameworkEndpoint.getSupportedType(),
  // Endpoint category classification
  frameworkEndpoint.getKind()