import python

/**
 * @name CWE-203: Observable Discrepancy
 * @description Detects potential observable discrepancy vulnerabilities in WebSocket implementations.
 * @id py/websocket
 */
from MessageReceive, DataProcessing
where MessageReceive.receivesData() and not DataProcessing.validatesInput()
select MessageReceive, "Potential CWE-203 vulnerability detected: Observable discrepancy in data processing."