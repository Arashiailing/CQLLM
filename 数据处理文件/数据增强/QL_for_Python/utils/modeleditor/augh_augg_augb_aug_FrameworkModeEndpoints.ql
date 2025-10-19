/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Identifies accessible endpoints (methods and attributes) available in the model editor's framework mode. 
 *              Excludes test and generated code artifacts from results.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

// Import ModelEditor capabilities for endpoint analysis
import modeling.ModelEditor

// Obtain framework-mode endpoint metadata
from Endpoint modelEndpoint
select 
  // Endpoint identification and classification
  modelEndpoint,
  modelEndpoint.getKind(),
  modelEndpoint.getFunctionName(),
  
  // Endpoint structural context
  modelEndpoint.getClass(),
  modelEndpoint.getNamespace(),
  
  // Endpoint functional specifications
  modelEndpoint.getParameters(),
  modelEndpoint.getSupportedType(),
  modelEndpoint.getSupportedStatus(),
  
  // Source code location
  modelEndpoint.getFileName()