/**
 * @name Model Editor Framework Mode Endpoints
 * @description This query enumerates all accessible endpoints (methods and attributes) within the model editor's framework mode, excluding test and generated code.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Utilize ModelEditor module to access model editing capabilities
import modeling.ModelEditor

// Extract endpoint details from the Endpoint class
from Endpoint endpoint
select 
  // Core endpoint object
  endpoint,
  // Namespace where the endpoint resides
  endpoint.getNamespace(),
  // Class containing the endpoint definition
  endpoint.getClass(),
  // Function name of the endpoint
  endpoint.getFunctionName(),
  // Parameter list for the endpoint
  endpoint.getParameters(),
  // Current support status of the endpoint
  endpoint.getSupportedStatus(),
  // Source file containing the endpoint
  endpoint.getFileName(),
  // Supported type classification
  endpoint.getSupportedType(),
  // Endpoint category classification
  endpoint.getKind()