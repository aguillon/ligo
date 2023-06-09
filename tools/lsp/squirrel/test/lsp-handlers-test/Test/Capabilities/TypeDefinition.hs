module Test.Capabilities.TypeDefinition (unit_type_definition) where

import Language.LSP.Test
import Language.LSP.Types (Location (..), Position (..), Range (..), filePathToUri, type (|?) (..))
import System.Directory (makeAbsolute)
import System.FilePath ((</>))

import Test.HUnit (Assertion)

import Test.Common.Capabilities.Util qualified as Common (contractsDir)
import Test.Common.FixedExpectations (shouldBe)
import Test.Common.LSP (openLigoDoc, runHandlersTest)

contractsDir :: FilePath
contractsDir = Common.contractsDir </> "find"

unit_type_definition :: Assertion
unit_type_definition = do
  let filename = "lambda.jsligo"

  eitherDefs <- runHandlersTest contractsDir $ do
    doc <- openLigoDoc filename
    getTypeDefinitions doc (Position 3 5)

  filepath <- makeAbsolute (contractsDir </> filename)
  let uri = filePathToUri filepath
  eitherDefs `shouldBe` InL [Location uri (Range (Position 0 5) (Position 0 11))]
