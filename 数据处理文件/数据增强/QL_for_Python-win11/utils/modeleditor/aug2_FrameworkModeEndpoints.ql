/**
 * @name Model Editor Framework Mode Endpoints
 * @description Provides a list of accessible endpoints (methods and attributes) for the model editor in framework mode, excluding test and generated code.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import the ModelEditor module for model editing functionality
import modeling.ModelEditor

// Retrieve endpoint information from the Endpoint class
from Endpoint apiEndpoint
select 
  // The endpoint object
  apiEndpoint,
  // Namespace of the endpoint
  apiEndpoint.getNamespace(),
  // Class containing the endpoint
  apiEndpoint.getClass(),
  // Function name of the endpoint
  apiEndpoint.getFunctionName(),
  // Parameters of the endpoint
  apiEndpoint.getParameters(),
  // Supported status of the endpoint
  apiEndpoint.getSupportedStatus(),
  // File where the endpoint is defined
  apiEndpoint.getFileName(),
  // Supported type of the endpoint
  apiEndpoint.getSupportedType(),
  // Kind of the endpoint
  apiEndpoint.getKind()