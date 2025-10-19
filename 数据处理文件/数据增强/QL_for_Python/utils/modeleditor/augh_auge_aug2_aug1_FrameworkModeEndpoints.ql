/**
 * @name Model Editor Framework Mode API Endpoints
 * @description Identifies and enumerates all publicly accessible API endpoints (methods/attributes) exposed by the library,
 *              excluding test code and automatically generated implementations. This query provides visibility into
 *              the public API surface area of the Model Editor framework when operating in framework mode.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  // Primary endpoint object - the fundamental representation of the API endpoint
  frameworkEndpoint,
  // Namespace information - identifies the module/package context of the endpoint
  frameworkEndpoint.getNamespace(),
  // Containing class - provides inheritance hierarchy information
  frameworkEndpoint.getClass(),
  // Endpoint identifier - the actual name as exposed to API consumers
  frameworkEndpoint.getFunctionName(),
  // Input parameters - defines the signature of accepted parameters
  frameworkEndpoint.getParameters(),
  // Response status codes - indicates possible HTTP status codes returned
  frameworkEndpoint.getSupportedStatus(),
  // File location - aids in code navigation and debugging
  frameworkEndpoint.getFileName(),
  // Supported data types - specifies the data types the endpoint can handle
  frameworkEndpoint.getSupportedType(),
  // Endpoint category - classifies the endpoint (e.g., method, attribute, etc.)
  frameworkEndpoint.getKind()