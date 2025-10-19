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

// Retrieve framework mode endpoint metadata
from Endpoint modelEditorEndpoint
select 
  // Endpoint identification and classification
  modelEditorEndpoint,
  modelEditorEndpoint.getKind(),
  modelEditorEndpoint.getFunctionName(),
  
  // Endpoint structural context
  modelEditorEndpoint.getClass(),
  modelEditorEndpoint.getNamespace(),
  
  // Endpoint functional specifications
  modelEditorEndpoint.getParameters(),
  modelEditorEndpoint.getSupportedType(),
  modelEditorEndpoint.getSupportedStatus(),
  
  // Source code location
  modelEditorEndpoint.getFileName()