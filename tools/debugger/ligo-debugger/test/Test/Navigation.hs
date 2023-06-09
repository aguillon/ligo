{-# OPTIONS_GHC -Wno-orphans #-}

-- | Tests on navigation through the snapshots and
-- responding to stepping commands.
module Test.Navigation
  ( module Test.Navigation
  ) where

import Fmt (pretty)
import Hedgehog (Gen, annotateShow, discard, forAll, forAllWith, property, (===))
import Hedgehog.Gen qualified as Gen
import Hedgehog.Range qualified as Range
import Test.Tasty (TestTree, testGroup)
import Test.Tasty.Hedgehog (testProperty)
import Text.Interpolation.Nyan

import Morley.Debugger.Core
  (Direction (..), MovementResult (..), NavigableSnapshot (getExecutedPosition),
  SourceLocation' (..), SrcLoc (..), curSnapshot, frozen, getCurMethodBlockLevel,
  getFutureSnapshotsNum, moveTill, switchBreakpoint)
import Morley.Debugger.DAP.Types (StepCommand' (..))
import Morley.Michelson.Parser.Types (MichelsonSource (..))
import Morley.Michelson.Text (mt)

import Language.LIGO.Debugger.Navigate
import Language.LIGO.Debugger.Snapshots

import Test.Util
import Test.Util.Golden

-- TODO: move these to Morley

deriving stock instance Show Direction

genDirection :: Gen Direction
genDirection = Gen.frequency [(7, pure Forward), (3, pure Backward)]

reverseDirection :: Direction -> Direction
reverseDirection = \case
  Forward -> Backward
  Backward -> Forward

-- Note: see the docs to 'processLigoStep' on rules for the expected
-- stepping behaviour

basicCaseRun :: Lang -> ContractRunData
basicCaseRun dialect = ContractRunData
  { crdProgram = contractsDir </> "functions-visiting" <.> langExtension dialect
  , crdEntrypoint = Nothing
  , crdParam = ()
  , crdStorage = 0 :: Integer
  }

{-

[LIGO-951]: finalize the tests.

-}
test_StepIn_golden :: TestTree
test_StepIn_golden = testGroup "StepIn" do
  gran <- allLigoStepGranularities
  let doStep = processLigoStep (CStepIn gran)
  pure $ testGroup [int||Granularity of #{gran}|] do
    dialect <- case gran of
      -- for statements the behaviour may differ for different dialects
      -- as they have custom format of code blocks
      GStmt -> allLangs
      _ -> one Caml
    [ goldenTestWithSnapshots [int||basic case, #s{dialect}, #{gran} granularity|]
        "StepIn"
        (basicCaseRun dialect)
        (dumpAllSnapshotsWithStep doStep)

      ]

test_Seq_node_doesn't_have_location :: TestTree
test_Seq_node_doesn't_have_location =
  let
    runData = ContractRunData
      { crdProgram = contractsDir </> "seq-nodes-without-locations.mligo"
      , crdEntrypoint = Nothing
      , crdParam = ()
      , crdStorage = 0 :: Integer
      }

    doStep = processLigoStep (CStepIn GExpExt)
  in goldenTestWithSnapshots
      "seq nodes dont have expression locations in snapshots"
      "StepIn"
      runData
      (dumpAllSnapshotsWithStep doStep)

test_top_level_function_with_preprocessor_don't_have_locations :: TestTree
test_top_level_function_with_preprocessor_don't_have_locations =
  let
    runData = ContractRunData
      { crdProgram = contractsDir </> "contract-with-preprocessor.mligo"
      , crdEntrypoint = Nothing
      , crdParam = ()
      , crdStorage = 0 :: Integer
      }

    doStep = processLigoStep (CStepIn GExpExt)
  in goldenTestWithSnapshots
      "top-level functions with preprocessor don't have expression locations in snapshots"
      "StepIn"
      runData
      (dumpAllSnapshotsWithStep doStep)

test_values_inside_switch_and_match_with_are_statements :: TestTree
test_values_inside_switch_and_match_with_are_statements =
  testGroup "Values inside \"switch\" and \"match ... with\" are statements" $
    [ ContractRunData
      { crdProgram = contractsDir </> "statement-in-match-branch.mligo"
      , crdEntrypoint = Nothing
      , crdParam = ()
      , crdStorage = 0 :: Integer
      }

    , ContractRunData
      { crdProgram = contractsDir </> "statements-in-case-branch.jsligo"
      , crdEntrypoint = Nothing
      , crdParam = [mt|Variant1|]
      , crdStorage = 0 :: Integer
      }
    ] <&> \runData -> do
      let doStep = processLigoStep (CStepIn GStmt)
      goldenTestWithSnapshots
        [int||checking for #{crdProgram runData} contract|]
        "StepIn"
        runData
        (dumpAllSnapshotsWithStep doStep)

test_local_function_assignments_are_statements :: TestTree
test_local_function_assignments_are_statements =
  let
    runData = ContractRunData
      { crdProgram = contractsDir </> "local-function-assignments.mligo"
      , crdEntrypoint = Nothing
      , crdParam = ()
      , crdStorage = 0 :: Integer
      }

    doStep = processLigoStep (CStepIn GStmt)
  in goldenTestWithSnapshots
      "local function assignments are statements"
      "StepIn"
      runData
      (dumpAllSnapshotsWithStep doStep)

test_Next_golden :: TestTree
test_Next_golden = testGroup "Next" do
  gran <- allLigoStepGranularities
  let doStep = processLigoStep (CNext Forward gran)
  pure $ testGroup [int||Granularity of #{gran}|]
    [ goldenTestWithSnapshots [int||go over top-level, granularity #{gran}|]
        "Next"
        (basicCaseRun Caml)
        do
          dumpAllSnapshotsWithStep $
            doStep <* do
              Just (SourceLocation _ (SrcLoc line _) _) <-
                lift $ frozen getExecutedPosition
              when (gran == GStmt && line < 10) do
                liftIO $ assertFailure [int||
                  We appeared at line #{line}, but we were not expected to visit
                  the functions `f` and `g`.
                  |]

    , goldenTestWithSnapshots [int||Go from within `f`, granularity #{gran}|]
        "Next"
        (basicCaseRun Caml)
        do
          moveTill Forward $ isAtLine 1
          [int||
            Starting from `f`'s beginning,
            should traverse `f`, skip `g`, and go to the end
            |]
          dumpAllSnapshotsWithStep doStep

    , testGroup "Interaction with breakpoints"
      [ goldenTestWithSnapshots
          [int||Breakpoint causes interrupt when we are going over function, \
                granularity #{gran}|]
          "Next"
          (basicCaseRun Caml)
          do
            switchBreakpoint
              (MSFile $ crdProgram $ basicCaseRun Caml)
              (SrcLoc 1 0)
            [int||Enabled breakpoint within `f`, but not within `g`|]
            dumpAllSnapshotsWithStep doStep

      ]

    ]

test_StepOut_golden :: TestTree
test_StepOut_golden = testGroup "StepOut" do
  gran <- allLigoStepGranularities
  let doStep = processLigoStep (CStepOut gran)
  pure $ testGroup [int||Granularity of #{gran}|]
    [ goldenTestWithSnapshots "Exit main function"
        "StepOut"
        (basicCaseRun Caml)
        do
          [int||Steping out immediately on start|]
          doStep
          dumpCurSnapshot

    , goldenTestWithSnapshots "Exit `f`"
        "StepOut"
        (basicCaseRun Caml)
        do
          moveTill Forward $ isAtLine 1
          [int||Should be within `f` now:|]
          dumpCurSnapshot

          [int||Jumping out of `f`:|]
          doStep
          dumpCurSnapshot

          [int||Jumping out of `main`:|]
          doStep
          dumpCurSnapshot

    , goldenTestWithSnapshots "Is not interfered by breakpoints"
        "StepOut"
        (basicCaseRun Caml)
        do
          switchBreakpoint
            (MSFile $ crdProgram $ basicCaseRun Caml)
            (SrcLoc 1 0)
          switchBreakpoint
            (MSFile $ crdProgram $ basicCaseRun Caml)
            (SrcLoc 2 0)
          processLigoStep (CContinue Forward)
          [int||Should be within `f` now:|]
          dumpCurSnapshot

          [int|n|
            Stepping out, now should appear outside of the method despite
            the breakpoint
            |]
          doStep
          dumpCurSnapshot

    ]

test_Continue_golden :: TestTree
test_Continue_golden = testGroup "Continue"
  let doStep = processLigoStep (CContinue Forward) in
  [ goldenTestWithSnapshots "Simple case with breakpoints"
      "Continue"
      (basicCaseRun Caml)
      do
        switchBreakpoint
          (MSFile $ crdProgram $ basicCaseRun Caml)
          (SrcLoc 11 0)
        [int||Breakpoint is set at `f` & `g` call|]
        dumpAllSnapshotsWithStep doStep
  ]

{-# ANN test_StepBackReversed ("HLint: ignore Redundant <$>" :: Text) #-}

test_StepBackReversed :: IO TestTree
test_StepBackReversed = fmap (testGroup "Step back is the opposite to Next") $
  [ ContractRunData
    { crdProgram = contractsDir </> "simple-ops.mligo"
    , crdEntrypoint = Nothing
    , crdParam = ()
    , crdStorage = 0 :: Integer
    }
  , ContractRunData
    { crdProgram = contractsDir </> "functions-assignments.mligo"
    , crdEntrypoint = Nothing
    , crdParam = ()
    , crdStorage = 0 :: Integer
    }
  , ContractRunData
    { crdProgram = contractsDir </> "module_contracts" </> "importer.mligo"
    , crdEntrypoint = Nothing
    , crdParam = ()
    , crdStorage = 0 :: Integer
    }

  ] `forM` \runData -> do
    locsAndHis <- liftIO $ mkSnapshotsForImpl dummyLoggingFunction runData
    return $ testProperty [int||On example of "#{crdProgram runData}"|] $
      property $ withSnapshots locsAndHis do
        let liftProp = lift . lift

        granularity <- liftProp $ forAllWith pretty genStepGranularity

        -- Jump to some position in the middle of execution.
        -- But at the position matching the current granularity.
        do
          futureSnapshotsNum <- frozen getFutureSnapshotsNum
          stepsNum <- liftProp . forAll $
            Gen.integral (Range.constant 0 futureSnapshotsNum)
          replicateM_ stepsNum $ processLigoStep (CStepIn granularity)

        isStatus <$> frozen curSnapshot >>= \case
          -- This property doesn't hold for @GStmt@ granularity
          -- in case of stopping at function call.
          InterpretRunning (EventExpressionPreview FunctionCall)
            | granularity == GStmt -> liftProp discard
          _ -> pass

        startPos <- frozen getExecutedPosition
        annotateShow startPos
        startMethodLevel <- frozen getCurMethodBlockLevel

        dir <- liftProp $ forAll genDirection

        -- Do a step over...
        do
          moveRes <- processLigoStep (CNext dir granularity)
          unless (moveRes == MovedSuccessfully) $
            -- We started at the end of the tape, this case is not interesting
            liftProp discard

        endMethodLevel <- frozen getCurMethodBlockLevel
        unless (startMethodLevel == endMethodLevel) $
          -- Exited current method, step back won't return to the old position
          liftProp discard

        annotateShow =<< frozen getExecutedPosition

        -- ...and then a step in the opposite direction
        processLigoStep (CNext (reverseDirection dir) granularity)

        -- Check this all resulted in no-op
        endPos <- frozen getExecutedPosition
        liftProp $ startPos === endPos

test_ContinueReversed :: TestTree
test_ContinueReversed = testGroup "Continueing back is the opposite to Continue"
  [  -- TODO: [LIGO-949]
  ]
