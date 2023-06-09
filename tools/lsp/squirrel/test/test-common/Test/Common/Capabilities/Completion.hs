module Test.Common.Capabilities.Completion
  ( TestInfo(..)
  , completionDriver
  , caseInfos
  ) where

import Algebra.Graph.AdjacencyMap qualified as G
import Language.LSP.Types (CompletionItemKind (..), UInt)
import System.Directory (canonicalizePath)
import System.FilePath ((</>))
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.HUnit (testCase)
import Unsafe qualified

import AST.Capabilities.Completion
import AST.Scope
import Log qualified
import Range (point)

import Test.Common.Capabilities.Util qualified (contractsDir)
import Test.Common.FixedExpectations (expectationFailure, shouldMatchList)
import Test.Common.Util (ScopeTester, parseDirectoryWithScopes)
import Util.Graph (traverseAM)

contractsDir :: FilePath
contractsDir = Test.Common.Capabilities.Util.contractsDir </> "completion"

data TestInfo = TestInfo
  { tiContract :: FilePath
  , tiPosition :: (UInt, UInt)
  , tiExpected :: [Completion]
  , tiGraph :: Includes FilePath
  }

-- Note: Not all completions will be in the completion list for VSCode. This is
-- because VSCode uses a fuzzy matcher, which can't be disabled, which further
-- filters the completion results.
-- See this for a discussion on the matter:
-- https://gitlab.com/serokell/ligo/ligo/-/merge_requests/176#note_679710028
caseInfos :: forall parser. ScopeTester parser => [TestInfo]
caseInfos =
  [ TestInfo
    { tiContract = "no-prefix.mligo"
    , tiPosition = (1, 33)
    , tiExpected = []
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "yes-prefix.mligo"
    , tiPosition = (1, 36)
    , tiExpected =
      [ Completion (Just CiVariable) (NameCompletion "parameter") (Just $ TypeCompletion "int") (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "type-attribute.mligo"
    , tiPosition = (13, 33)
    , tiExpected =
      [ Completion (Just CiField) (NameCompletion "id") (Just $ TypeCompletion "nat") (DocCompletion "")
      , Completion (Just CiField) (NameCompletion "is_admin") (Just $ TypeCompletion "bool") (DocCompletion "")
      , CompletionKeyword (NameCompletion "if")
      , CompletionKeyword (NameCompletion "begin")
      , CompletionKeyword (NameCompletion "with")
      , CompletionKeyword (NameCompletion "in")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "type-attribute.jsligo"
    , tiPosition = (13, 33)
    , tiExpected =
      [ Completion (Just CiField) (NameCompletion "id") (Just $ TypeCompletion "nat") (DocCompletion "")
      , Completion (Just CiField) (NameCompletion "is_admin") (Just $ TypeCompletion "bool") (DocCompletion "")
      , CompletionKeyword (NameCompletion "if")
      , CompletionKeyword (NameCompletion "switch")
      , CompletionKeyword (NameCompletion "while")
      , CompletionKeyword (NameCompletion "import")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "type-constructor.mligo"
    , tiPosition = (5, 19)
    , tiExpected =
      [ Completion (Just CiConstructor) (NameCompletion "Increment") (Just $ TypeCompletion "action") (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "type-constructor.jsligo"
    , tiPosition = (5, 19)
    , tiExpected =
      [ Completion (Just CiConstructor) (NameCompletion "Increment") (Just $ TypeCompletion "action") (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }

  , TestInfo
    { tiContract = "unfinished-field-name.mligo"
    , tiPosition = (8, 27)
    , tiExpected =
      [ Completion (Just CiField) (NameCompletion "sum") (Just $ TypeCompletion "int") (DocCompletion "")
      , CompletionKeyword (NameCompletion "struct")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "nested-fields.mligo"
    , tiPosition = (18, 36)
    , tiExpected =
      [ Completion (Just CiField) (NameCompletion "series") (Just $ TypeCompletion "int") (DocCompletion "")
      , CompletionKeyword (NameCompletion "struct")
      , CompletionKeyword (NameCompletion "lsl")
      , CompletionKeyword (NameCompletion "else")
      , CompletionKeyword (NameCompletion "lsr")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "nested-fields.jsligo"
    , tiPosition = (18, 35)
    , tiExpected =
      [ Completion (Just CiField) (NameCompletion "series") (Just $ TypeCompletion "int") (DocCompletion "")
      , CompletionKeyword (NameCompletion "as")
      , CompletionKeyword (NameCompletion "switch")
      , CompletionKeyword (NameCompletion "namespace")
      , CompletionKeyword (NameCompletion "case")
      , CompletionKeyword (NameCompletion "else")
      , CompletionKeyword (NameCompletion "const")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "incr.mligo"
    , tiPosition = (3, 13)
    , tiExpected =
      [ let t = case knownScopingSystem @parser of
                  FallbackScopes -> "nat" -- FIXME LIGO-942
                  _ -> "nat -> nat"
        in Completion (Just CiFunction) (NameCompletion "incr_my_stuff") (Just $ TypeCompletion t) (DocCompletion "")
      , CompletionKeyword (NameCompletion "begin")
      , CompletionKeyword (NameCompletion "in")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "import/outer-includer.jsligo"
    , tiPosition = (1, 11)
    , tiExpected =
        [ ImportCompletion (NameCompletion "outer-includer2.jsligo")
        , ImportCompletion (NameCompletion "innerFolder/inner-includer.jsligo")
        ]
    , tiGraph = Includes $ G.vertices
        [ "./test/contracts/completion/import/outer-includer.jsligo"
        , "./test/contracts/completion/import/outer-includer2.jsligo"
        , "./test/contracts/completion/import/innerFolder/inner-includer.jsligo"
        ]
    }
  , TestInfo
    { tiContract = "import/innerFolder/inner-includer.jsligo"
    , tiPosition = (1, 11)
    , tiExpected =
        [ ImportCompletion (NameCompletion "../outer-includer2.jsligo")
        , ImportCompletion (NameCompletion "../outer-includer.jsligo")
        ]
    , tiGraph = Includes $ G.vertices
        [ "./test/contracts/completion/import/outer-includer.jsligo"
        , "./test/contracts/completion/import/outer-includer2.jsligo"
        , "./test/contracts/completion/import/innerFolder/inner-includer.jsligo"
        ]
    }
  , TestInfo
    { tiContract = "modules.mligo"
    , tiPosition = (8, 26)
    , tiExpected =
      [ Completion (Just CiVariable) (NameCompletion "nested") (Just $ TypeCompletion "int") (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "modules2.mligo"
    , tiPosition = (5, 24)
    , tiExpected =
      [ Completion (Just CiVariable) (NameCompletion "bar") (Just $ TypeCompletion "int") (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "module-field.mligo"
    , tiPosition = (8, 26)
    , tiExpected =
      [ Completion (Just CiVariable) (NameCompletion "baz") (Just $ TypeCompletion "int") (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "local-namespace.mligo"
    , tiPosition = (2, 30)
    , tiExpected =
      [ Completion (Just CiVariable) (NameCompletion "baz") (Just $ TypeCompletion "int") (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "nested-modules.mligo"
    , tiPosition = (14, 25)
    , tiExpected =
      [ let (k, t) = case knownScopingSystem @parser of
                      FallbackScopes -> (Nothing, Nothing) -- Fallback can't infer types here
                      _ -> (Just CiVariable, Just $ TypeCompletion "int")
        in Completion k (NameCompletion "baz") t (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  , TestInfo
    { tiContract = "nested-modules.mligo"
    , tiPosition = (15, 27)
    , tiExpected =
      [ let (k, t) = case knownScopingSystem @parser of
                      FallbackScopes -> (Nothing, Nothing) -- Fallback can't infer types here
                      _ -> (Just CiVariable, Just $ TypeCompletion "int")
        in Completion k (NameCompletion "bax") t (DocCompletion "")
      ]
    , tiGraph = Includes G.empty
    }
  ]

completionDriver :: forall parser. ScopeTester parser => [TestInfo] -> IO TestTree
completionDriver testInfos = do
  graph <- parseDirectoryWithScopes @parser contractsDir
  pure $ testGroup "Completion" $ map (makeTestCase graph) testInfos
  where
    makeTestCase graph info =
      testCase (tiContract info) do
        let fp = contractsDir </> tiContract info
            pos = uncurry point $ tiPosition info
            contract = Unsafe.fromJust $ lookupContract fp graph
            tree = contractTree contract
            source = _cFile $ _getContract contract
        tiGraphNormalized <- Includes <$> traverseAM canonicalizePath (getIncludes $ tiGraph info)
        results <- Log.runNoLoggingT $ withCompleterM (CompleterEnv pos tree source tiGraphNormalized) complete
        case (results, tiExpected info) of
          (Nothing, []) -> pass
          (Nothing, _) -> expectationFailure "Expected completion items, but got none"
          (Just [], []) -> pass
          (Just _, []) -> expectationFailure "Expected no completion items, but got them"
          (Just results', expected') -> results' `shouldMatchList` expected'
