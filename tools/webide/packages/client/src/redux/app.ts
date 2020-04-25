import { combineReducers } from 'redux';

import command, { CommandState } from './command';
import compile, { CompileState } from './compile';
import deploy, { DeployState } from './deploy';
import dryRun, { DryRunState } from './dry-run';
import editor, { EditorState } from './editor';
import evaluateFunction, { EvaluateFunctionState } from './evaluate-function';
import evaluateValue, { EvaluateValueState } from './evaluate-value';
import examples, { ExamplesState } from './examples';
import generateCommand, { GenerateCommandState } from './generate-command';
import loading, { LoadingState } from './loading';
import result, { ResultState } from './result';
import share, { ShareState } from './share';
import version, { VersionState } from './version';

export interface AppState {
  version: VersionState;
  editor: EditorState;
  share: ShareState;
  compile: CompileState;
  dryRun: DryRunState;
  deploy: DeployState;
  evaluateFunction: EvaluateFunctionState;
  evaluateValue: EvaluateValueState;
  generateCommand: GenerateCommandState;
  result: ResultState;
  command: CommandState;
  examples: ExamplesState;
  loading: LoadingState;
}

export default combineReducers({
  editor,
  share,
  compile,
  dryRun,
  deploy,
  evaluateFunction,
  evaluateValue,
  generateCommand,
  result,
  command,
  examples,
  loading,
  version
});
