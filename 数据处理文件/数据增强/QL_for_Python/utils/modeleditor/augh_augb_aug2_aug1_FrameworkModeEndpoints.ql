/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Discovers and catalogs all accessible API endpoints (methods/attributes) 
 *              within the ModelEditor framework, filtering out test and generated code
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

// Retrieve all API endpoints exposed by the ModelEditor framework
from Endpoint frameworkEndpoint
select 
  // Core endpoint identification
  frameworkEndpoint,                              // Reference to the API endpoint
  frameworkEndpoint.getClass(),                  // Containing class of the endpoint
  frameworkEndpoint.getNamespace(),              // Namespace where the endpoint resides
  
  // Functional characteristics
  frameworkEndpoint.getFunctionName(),           // Name of the function/method
  frameworkEndpoint.getParameters(),             // List of parameters in the signature
  frameworkEndpoint.getSupportedStatus(),        // HTTP status codes supported
  
  // Classification and metadata
  frameworkEndpoint.getKind(),                    // Type/category of the endpoint
  frameworkEndpoint.getSupportedType(),          // Data types supported by the endpoint
  frameworkEndpoint.getFileName()                // Source file containing the endpoint