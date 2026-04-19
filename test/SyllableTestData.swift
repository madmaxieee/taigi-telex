import Foundation

@testable import TaigiTelexLib

/// Represents a single syllable test case with expected outputs for all tone variations
public struct SyllableTestCase {
  public let mode: InputMode  // .tl or .poj
  public let input: String  // Raw input
  public let output: String  // Expected output with correct tone marks

  public init(mode: InputMode, input: String, output: String) {
    self.mode = mode
    self.input = input
    self.output = output
  }

  public static func tl(in input: String, out output: String) -> SyllableTestCase {
    return SyllableTestCase(mode: .tl, input: input, output: output)
  }

  public static func poj(in input: String, out output: String) -> SyllableTestCase {
    return SyllableTestCase(mode: .poj, input: input, output: output)
  }
}

extension SyllableTestCase {
  // Basic test cases from examples in README

  static let tlBasic: [SyllableTestCase] = [
    // Tone marks
    .tl(in: "tev", out: "té"),
    .tl(in: "khooy", out: "khòo"),
    .tl(in: "langd", out: "lâng"),
    .tl(in: "kangw", out: "kāng"),
    .tl(in: "titx", out: "ti̍t"),
    .tl(in: "zangq", out: "tsa̋ng"),
    // Consonant replacements
    .tl(in: "z", out: "ts"),
    .tl(in: "c", out: "tsh"),
  ]

  static let pojBasic: [SyllableTestCase] = [
    // Tone marks with POJ-specific vowels
    .poj(in: "hoov", out: "hó͘"),
    .poj(in: "pay", out: "pà"),
    .poj(in: "kaud", out: "kâu"),
    .poj(in: "ciunnw", out: "chhiūⁿ"),
    .poj(in: "lokx", out: "lo̍k"),
    .poj(in: "zangq", out: "chăng"),
    // Nasalization
    .poj(in: "sann", out: "saⁿ"),
    // Consonant replacements
    .poj(in: "z", out: "ch"),
    .poj(in: "c", out: "chh"),
  ]
}
