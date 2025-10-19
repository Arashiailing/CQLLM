/**
 * @name Overly permissive file permissions
 * @description Detects file operations with overly permissive access rights that may expose sensitive data
 * @kind problem
 * @id py/overly-permissive-file
 * @problem.severity warning
 * @security-severity 7.8
 * @sub-severity high
 * @precision medium
 * @tags external/cwe/cwe-732
 *       security
 */

import python
import semmle.python.ApiGraphs

/**
 * Extracts the world-accessible permission bits (least significant 3 bits) from a full permission mask.
 * @param fullPermission The complete permission value (e.g., 0o777)
 * @return The world permission component (0-7)
 */
bindingset[fullPermission]
int getWorldPermissionBits(int fullPermission) { 
  result = fullPermission % 8 
}

/**
 * Extracts the group-accessible permission bits (middle 3 bits) from a full permission mask.
 * @param fullPermission The complete permission value (e.g., 0o777)
 * @return The group permission component (0-7)
 */
bindingset[fullPermission]
int getGroupPermissionBits(int fullPermission) { 
  result = (fullPermission / 8) % 8 
}

/**
 * Generates a human-readable description of permission components.
 * @param permissionComponent The permission bits to describe (0-7)
 * @return "writable" if write permission is set, "readable" if only read permission is set
 */
bindingset[permissionComponent]
string describePermissionLevel(int permissionComponent) {
  permissionComponent % 4 >= 2 and result = "writable"
  or
  permissionComponent % 4 < 2 and permissionComponent != 0 and result = "readable"
}

/**
 * Identifies overly permissive permission components in a file permission mask.
 * @param fullPermission The complete permission value to analyze
 * @return Description of the permissive component (e.g., "world writable")
 */
bindingset[fullPermission]
string detectPermissiveComponent(int fullPermission) {
  // Check world permissions first (higher risk)
  exists(int worldPerm | 
    worldPerm = getWorldPermissionBits(fullPermission) and
    result = "world " + describePermissionLevel(worldPerm)
  )
  or
  // Only check group permissions if world permissions are restricted
  getWorldPermissionBits(fullPermission) = 0 and 
  exists(int groupPerm | 
    groupPerm = getGroupPermissionBits(fullPermission) and
    result = "group " + describePermissionLevel(groupPerm)
  )
}

/**
 * Matches os.chmod calls and extracts the permission mode parameter.
 * @param apiCall The API call node
 * @param operationType Always "chmod" for this predicate
 * @param permissionMode The permission mode value
 */
predicate isChmodOperation(API::CallNode apiCall, string operationType, int permissionMode) {
  apiCall = API::moduleImport("os").getMember("chmod").getACall() and
  permissionMode = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  operationType = "chmod"
}

/**
 * Matches os.open calls and extracts the permission mode parameter.
 * @param apiCall The API call node
 * @param operationType Always "open" for this predicate
 * @param permissionMode The permission mode value
 */
predicate isOpenOperation(API::CallNode apiCall, string operationType, int permissionMode) {
  apiCall = API::moduleImport("os").getMember("open").getACall() and
  permissionMode = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  operationType = "open"
}

// Identify file permission API calls with overly permissive modes
from API::CallNode apiCall, string operationType, int permissionMode, string permissiveDescription
where
  (isChmodOperation(apiCall, operationType, permissionMode) or 
   isOpenOperation(apiCall, operationType, permissionMode)) and
  permissiveDescription = detectPermissiveComponent(permissionMode)
select apiCall, "Overly permissive mask in " + operationType + " sets file to " + permissiveDescription + "."