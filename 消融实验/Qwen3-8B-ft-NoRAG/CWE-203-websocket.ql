import py

/**
 * @name CWE-203: Observable Discrepancy
 * @description Detects observable discrepancies in WebSocket communication that may lead to information leakage.
 * @id py/websocket
 */
from MsgSend s, Call c, StringLiteral sl
where
  s.getDecl() = c.getDecl() and
  c.getKind() = "Call" and
  c.getExpr() = sl and
  sl.getValue() = "print" or
  sl.getValue() = "logging.info" and
  c.getArgument(0).getType().getName() = "str" and
  c.getArgument(0).getKind() = "StringLiteral" and
  c.getArgument(0).getValue() like "%websocket%" or
  c.getArgument(0).getKind() = "Variable" and
  c.getArgument(0).getVariable().getName() = "message"
select c, "Potential observable discrepancy detected in WebSocket communication."