/**
 * @name Alert suppression
 * @description Identifies and analyzes alert suppression mechanisms in Python code, focusing on noqa-style comments.
 * @kind alert-suppression
 * @id py/alert-suppression
 */

// Import alert suppression utilities for handling suppression mechanisms
private import codeql.util.suppression.AlertSuppression as AS
// Import Python comment processing utilities for source code analysis
private import semmle.python.Comment as P

/**
 * Represents a Python single-line comment with enhanced location tracking.
 * This class extends the base Comment class to provide precise location information.
 */
class LineComment instanceof P::Comment {
  /**
   * Determines the precise location of this comment in source code.
   * @param sourceFile The path to the source file containing the comment
   * @param startLine The starting line number of the comment
   * @param startCol The starting column number of the comment
   * @param endLine The ending line number of the comment
   * @param endCol The ending column number of the comment
   */
  predicate hasLocationInfo(
    string sourceFile, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, startLine, startCol, endLine, endCol)
  }

  /**
   * Retrieves the raw text content of this comment.
   * @return The comment's text content as a string
   */
  string getText() { result = super.getContents() }

  /**
   * Provides a string representation of this comment.
   * @return A descriptive string representing the comment
   */
  string toString() { result = super.toString() }
}

/**
 * Represents a Python AST node with precise location tracking.
 * This class extends the base AstNode class to provide detailed location information.
 */
class CodeNode instanceof P::AstNode {
  /**
   * Determines the precise location of this AST node in source code.
   * @param sourceFile The path to the source file containing the node
   * @param startLine The starting line number of the node
   * @param startCol The starting column number of the node
   * @param endLine The ending line number of the node
   * @param endCol The ending column number of the node
   */
  predicate hasLocationInfo(
    string sourceFile, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(sourceFile, startLine, startCol, endLine, endCol)
  }

  /**
   * Provides a string representation of this AST node.
   * @return A descriptive string representing the AST node
   */
  string toString() { result = super.toString() }
}

// Generate suppression relationships using AS template for CodeNode and LineComment
import AS::Make<CodeNode, LineComment>

/**
 * Represents a noqa-style suppression comment recognized by Python linters.
 * This class handles comments that suppress warnings using the noqa convention.
 */
class NoqaStyleSuppression extends SuppressionComment instanceof LineComment {
  /**
   * Matches comments containing the noqa keyword (case-insensitive), 
   * optionally followed by additional content.
   */
  NoqaStyleSuppression() {
    LineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  /**
   * Gets the annotation identifier for this suppression.
   * @return The string "lgtm" as the annotation identifier
   */
  override string getAnnotation() { result = "lgtm" }

  /**
   * Determines the scope of the suppression: the entire line of the comment, 
   * starting from column 1.
   * @param sourceFile Path to the source file
   * @param startLine Starting line number of the suppression
   * @param startCol Starting column number (always 1)
   * @param endLine Ending line number
   * @param endCol Ending column number
   */
  override predicate covers(
    string sourceFile, int startLine, int startCol, int endLine, int endCol
  ) {
    // Enforce line-start position and match comment location
    startCol = 1 and
    this.hasLocationInfo(sourceFile, startLine, _, endLine, endCol)
  }
}