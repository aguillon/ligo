module Test.Integrational.Diagnostics
  ( unit_bad_parse
  ) where

import Data.Text (Text)

import AST.Scope (Standard)
import Range (Range (..))

import Test.Common.Diagnostics (inputFile, parseDiagnosticsDriver)
import Test.Common.FixedExpectations (HasCallStack)
import Test.Tasty.HUnit (Assertion)

expectedMsgs :: [(Range, Text)]
expectedMsgs =
  [ (mkRange (3, 17) (3, 23), "Unexpected: :: int")
  , (mkRange (3, 17) (3, 23), "Unexpected: :: int")
  , (mkRange (3, 17) (3, 23), "Unrecognized: :: int")
  , (mkRange (3, 20) (3, 23), "Unrecognized: int")
  ]
  where
    mkRange :: (Int, Int) -> (Int, Int) -> Range
    mkRange (a, b) (c, d) = Range (a, b, 0) (c, d, 0) inputFile

-- Try to parse a file, and check that the proper error messages are generated
unit_bad_parse :: HasCallStack => Assertion
unit_bad_parse = parseDiagnosticsDriver @Standard expectedMsgs
