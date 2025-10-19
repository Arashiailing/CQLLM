/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Identifies accessible API endpoints (methods/attributes) for library consumers, excluding test and generated code
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

// Query all API endpoints from the ModelEditor framework
from Endpoint exposedEndpoint
select 
  // Basic endpoint information
  exposedEndpoint,                                // Core API endpoint reference
  exposedEndpoint.getNamespace(),                // Namespace context for the endpoint
  exposedEndpoint.getClass(),                    // Parent class containing the endpoint
  
  // Functional details
  exposedEndpoint.getFunctionName(),             // Function/method name identifier
  exposedEndpoint.getParameters(),               // Parameter signature list
  exposedEndpoint.getSupportedStatus(),          // Supported HTTP status codes
  
  // Metadata and classification
  exposedEndpoint.getFileName(),                  // Source file location
  exposedEndpoint.getSupportedType(),            // Supported data types
  exposedEndpoint.getKind()                       // Endpoint classification type