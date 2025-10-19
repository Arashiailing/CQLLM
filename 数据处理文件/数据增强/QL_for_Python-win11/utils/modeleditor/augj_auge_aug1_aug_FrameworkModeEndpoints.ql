/**
 * @name Framework-mode endpoint catalog for model editor
 * @description Catalogs production endpoints in model editor framework mode,
 *              excluding test/auto-generated code. Captures both methods and
 *              attributes with their metadata including signatures, types,
 *              and HTTP status support.
 * @kind table
 * @id py/utils/modeleditor/framework-mode-endpoints
 * @tags modeleditor endpoints framework-mode
 */

import modeling.ModelEditor

from Endpoint frameworkEndpoint
select 
  frameworkEndpoint,
  frameworkEndpoint.getNamespace(),
  frameworkEndpoint.getClass(),
  frameworkEndpoint.getFunctionName(),
  frameworkEndpoint.getParameters(),
  frameworkEndpoint.getSupportedStatus(),
  frameworkEndpoint.getFileName(),
  frameworkEndpoint.getSupportedType(),
  frameworkEndpoint.getKind()