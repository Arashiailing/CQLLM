/**
 * @name Alert suppression
 * @description Provides details about alert suppression mechanisms in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import CodeQL alert suppression utilities for managing suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import Python comment processing utilities for comment analysis
private import semmle.python.Comment as PyComment

// Represents AST nodes with location tracking capabilities
class AstNode instanceof PyComment::AstNode {
  // Check if node's location matches specified coordinates
  predicate hasLocationInfo(
    string path, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(path, startLine, startCol, endLine, endCol)
  }

  // Generate string representation of AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments with precise location tracking
class SingleLineComment instanceof PyComment::Comment {
  // Verify comment location matches given coordinates
  predicate hasLocationInfo(
    string path, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(path, startLine, startCol, endLine, endCol)
  }

  // Retrieve textual content of comment
  string getText() { result = super.getContents() }

  // Generate string representation of comment
  string toString() { result = super.toString() }
}

// Apply suppression relationship generation using AlertSuppUtil template
import AlertSuppUtil::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. This type of comment is recognized by both pylint and pyflakes,
 * and therefore should also be respected by LGTM.
 */
// Denotes suppression comments that follow the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that identifies noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Yields the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Specifies the code coverage range for this suppression annotation
  override predicate covers(
    string path, int startLine, int startCol, int endLine, int endCol
  ) {
    // Confirm comment location matches and starts at line beginning
    this.hasLocationInfo(path, startLine, _, endLine, endCol) and
    startCol = 1
  }
}