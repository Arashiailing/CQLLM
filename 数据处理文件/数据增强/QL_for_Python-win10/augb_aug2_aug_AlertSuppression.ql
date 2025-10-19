/**
 * @name Alert suppression
 * @description This module offers comprehensive details about the mechanisms used to suppress alerts in Python code.
 * @kind alert-suppression
 * @id py/alert-suppression */

// Import utilities for alert suppression from CodeQL to manage suppression logic
private import codeql.util.suppression.AlertSuppression as AlertSuppUtil
// Import utilities for processing Python comments to facilitate comment analysis
private import semmle.python.Comment as PyComment

// Represents AST nodes equipped with advanced location tracking features
class AstNode instanceof PyComment::AstNode {
  // Check if the node's location matches the specified coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Produce a string representation of the AST node
  string toString() { result = super.toString() }
}

// Represents single-line comments featuring accurate location tracking
class SingleLineComment instanceof PyComment::Comment {
  // Ascertain whether the comment's location aligns with the given coordinates
  predicate hasLocationInfo(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    super.getLocation().hasLocationInfo(filePath, startLine, startCol, endLine, endCol)
  }

  // Retrieve the textual content of the comment
  string getText() { result = super.getContents() }

  // Furnish a string representation of the comment
  string toString() { result = super.toString() }
}

// Apply suppression relationship generation using AlertSuppUtil template
import AlertSuppUtil::Make<AstNode, SingleLineComment>

/**
 * Represents a noqa suppression comment. This type of comment is recognized by both pylint and pyflakes,
 * and therefore should also be respected by lgtm.
 */
// Denotes suppression comments that adhere to the noqa standard
class NoqaSuppressionComment extends SuppressionComment instanceof SingleLineComment {
  // Constructor that recognizes noqa comment patterns
  NoqaSuppressionComment() {
    SingleLineComment.super.getText().regexpMatch("(?i)\\s*noqa\\s*([^:].*)?")
  }

  // Yields the suppression annotation identifier
  override string getAnnotation() { result = "lgtm" }

  // Specifies the code coverage range for this suppression annotation
  override predicate covers(
    string filePath, int startLine, int startCol, int endLine, int endCol
  ) {
    // Confirm that the comment's location matches and that it starts at the beginning of the line
    this.hasLocationInfo(filePath, startLine, _, endLine, endCol) and
    startCol = 1
  }
}