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
from Endpoint frameworkEndpoint
select 
  // Endpoint identification and classification
  frameworkEndpoint,
  frameworkEndpoint.getKind(),
  frameworkEndpoint.getFunctionName(),
  
  // Endpoint structural context
  frameworkEndpoint.getClass(),
  frameworkEndpoint.getNamespace(),
  
  // Endpoint functional specifications
  frameworkEndpoint.getParameters(),
  frameworkEndpoint.getSupportedType(),
  frameworkEndpoint.getSupportedStatus(),
  
  // Source code location
  frameworkEndpoint.getFileName()