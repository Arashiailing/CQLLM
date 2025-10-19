/**
 * @name Overly permissive file permissions
 * @description Allowing files to be readable or writable by users other than the owner may allow sensitive information to be accessed.
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
 * Extracts the world permission bits (least significant 3 bits) from a file permission value.
 * @param permissionValue The full permission value (e.g., 0o777)
 * @return The world permission component (0-7)
 */
bindingset[permissionValue]
int extractWorldPermission(int permissionValue) { 
  result = permissionValue % 8 
}

/**
 * Extracts the group permission bits (middle 3 bits) from a file permission value.
 * @param permissionValue The full permission value (e.g., 0o777)
 * @return The group permission component (0-7)
 */
bindingset[permissionValue]
int extractGroupPermission(int permissionValue) { 
  result = (permissionValue / 8) % 8 
}

/**
 * Generates a human-readable description of permission bits.
 * @param permissionBits The permission component to describe (0-7)
 * @return "writable" if write permission is set, "readable" if only read permission is set
 */
bindingset[permissionBits]
string describePermission(int permissionBits) {
  permissionBits % 4 >= 2 and result = "writable"
  or
  permissionBits % 4 < 2 and permissionBits != 0 and result = "readable"
}

/**
 * Identifies overly permissive permission components in a file permission value.
 * @param permissionValue The full permission value to analyze
 * @return Description of the permissive component (e.g., "world writable")
 */
bindingset[permissionValue]
string identifyPermissiveComponent(int permissionValue) {
  result = "world " + describePermission(extractWorldPermission(permissionValue))
  or
  extractWorldPermission(permissionValue) = 0 and 
  result = "group " + describePermission(extractGroupPermission(permissionValue))
}

/**
 * Matches os.chmod calls and extracts the permission mode parameter.
 * @param call The API call node
 * @param funcName Always "chmod" for this predicate
 * @param mode The permission mode value
 */
predicate isChmodCall(API::CallNode call, string funcName, int mode) {
  call = API::moduleImport("os").getMember("chmod").getACall() and
  mode = call.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  funcName = "chmod"
}

/**
 * Matches os.open calls and extracts the permission mode parameter.
 * @param call The API call node
 * @param funcName Always "open" for this predicate
 * @param mode The permission mode value
 */
predicate isOpenCall(API::CallNode call, string funcName, int mode) {
  call = API::moduleImport("os").getMember("open").getACall() and
  mode = call.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  funcName = "open"
}

// Find file permission API calls with overly permissive modes
from API::CallNode call, string funcName, int mode, string permissionDescription
where
  (isChmodCall(call, funcName, mode) or isOpenCall(call, funcName, mode)) and
  permissionDescription = identifyPermissiveComponent(mode)
select call, "Overly permissive mask in " + funcName + " sets file to " + permissionDescription + "."