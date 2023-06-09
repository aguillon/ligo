module Test.Capabilities.DocumentSymbol
  ( unit_document_symbols_example_let_camligo
  , unit_document_symbols_example_let_jsligo
  , unit_document_symbols_cameligo_modules
  ) where

import AST.Scope (Fallback)

import Test.Common.Capabilities.DocumentSymbol
import Test.HUnit (Assertion)

unit_document_symbols_example_let_camligo :: Assertion
unit_document_symbols_example_let_camligo = documentSymbolsExampleLetCamligoDriver @Fallback

unit_document_symbols_example_let_jsligo :: Assertion
unit_document_symbols_example_let_jsligo = documentSymbolsExampleLetJsligoDriver @Fallback

unit_document_symbols_cameligo_modules :: Assertion
unit_document_symbols_cameligo_modules = documentSymbolsCameligoModules @Fallback
