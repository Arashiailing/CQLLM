/**
 * @name Overly permissive file permissions
 * @description Detects file operations with permissions that allow non-owner access, potentially exposing sensitive data.
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
 * Extracts the world-accessible permission bits (last 3 bits) from a file mode value.
 * @param modeValue The complete permission mode (e.g., 0o777)
 * @return The world permission component (0-7)
 */
bindingset[modeValue]
int extractWorldPermission(int modeValue) { 
  result = modeValue % 8 
}

/**
 * Extracts the group permission bits (middle 3 bits) from a file mode value.
 * @param modeValue The complete permission mode (e.g., 0o777)
 * @return The group permission component (0-7)
 */
bindingset[modeValue]
int extractGroupPermission(int modeValue) { 
  result = (modeValue / 8) % 8 
}

/**
 * Generates human-readable permission descriptions based on bit flags.
 * @param permBits Permission component to analyze (0-7)
 * @return "writable" if write bit is set, "readable" if only read bit is set
 */
bindingset[permBits]
string describePermission(int permBits) {
  permBits % 4 >= 2 and result = "writable"
  or
  permBits % 4 < 2 and permBits != 0 and result = "readable"
}

/**
 * Identifies overly permissive components in file permission modes.
 * @param modeValue The complete permission mode to analyze
 * @return Description of the permissive component (e.g., "world writable")
 */
bindingset[modeValue]
string identifyPermissiveComponent(int modeValue) {
  result = "world " + describePermission(extractWorldPermission(modeValue))
  or
  extractWorldPermission(modeValue) = 0 and 
  result = "group " + describePermission(extractGroupPermission(modeValue))
}

/**
 * Matches os.chmod API calls and extracts permission mode parameter.
 * @param apiCall The API call node
 * @param funcName Always "chmod" for this predicate
 * @param permMode The permission mode value
 */
predicate isChmodCall(API::CallNode apiCall, string funcName, int permMode) {
  apiCall = API::moduleImport("os").getMember("chmod").getACall() and
  permMode = apiCall.getParameter(1, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  funcName = "chmod"
}

/**
 * Matches os.open API calls and extracts permission mode parameter.
 * @param apiCall The API call node
 * @param funcName Always "open" for this predicate
 * @param permMode The permission mode value
 */
predicate isOpenCall(API::CallNode apiCall, string funcName, int permMode) {
  apiCall = API::moduleImport("os").getMember("open").getACall() and
  permMode = apiCall.getParameter(2, "mode").getAValueReachingSink().asExpr().(IntegerLiteral).getValue() and
  funcName = "open"
}

// Detect file permission API calls with overly permissive modes
from API::CallNode apiCall, string funcName, int permMode, string permDesc
where
  (isChmodCall(apiCall, funcName, permMode) or isOpenCall(apiCall, funcName, permMode)) and
  permDesc = identifyPermissiveComponent(permMode)
select apiCall, "Overly permissive mask in " + funcName + " sets file to " + permDesc + "."