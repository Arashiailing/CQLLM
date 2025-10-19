import python

/**
 * @name CWE-120: Buffer Copy without Checking Size of Input ('Classic Buffer Overflow')
 * @description The product copies an input buffer to an output buffer without verifying that the size of the input buffer is less than the size of the output buffer. 
 * @id py/bufferedwriter.pyx
 */

from FunctionCall fc, Variable inputBuffer, Variable outputBuffer, BinaryExpr bufferSizeCheck
where
  fc.getTarget().getName() = "write" and
  fc.getArgument(0) instanceof Variable and
  fc.getArgument(0) = inputBuffer and
  fc.getArgument(1) instanceof Variable and
  fc.getArgument(1) = outputBuffer and
  not exists(BinaryExpr bufferSizeCheck |
    bufferSizeCheck.getLeft() = inputBuffer and
    bufferSizeCheck.getRight() = outputBuffer and
    (bufferSizeCheck.getOperator() = "<" or bufferSizeCheck.getOperator() = "<=")
  )
select fc, "This function call may lead to a buffer overflow because it does not check if the input buffer size is less than the output buffer size."