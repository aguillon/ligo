import { ActionType as ExamplesActionType, ChangeSelectedAction as ChangeSelectedExampleAction } from './examples';

export enum ActionType {
  ChangeEntrypoint = 'dry-run-change-entrypoint',
  ChangeParameters = 'dry-run-change-parameters',
  ChangeStorage = 'dry-run-change-storage',
  ChangeProtocol = 'dry-run-change-protocol'
}

export interface DryRunState {
  entrypoint: string;
  parameters: string;
  storage: string;
  protocol : string;
}

export class ChangeEntrypointAction {
  public readonly type = ActionType.ChangeEntrypoint;
  constructor(public payload: DryRunState['entrypoint']) {}
}

export class ChangeParametersAction {
  public readonly type = ActionType.ChangeParameters;
  constructor(public payload: DryRunState['parameters']) {}
}

export class ChangeProtocolAction {
  public readonly type = ActionType.ChangeProtocol;
  constructor(public payload: DryRunState['protocol']) {}
}

export class ChangeStorageAction {
  public readonly type = ActionType.ChangeStorage;
  constructor(public payload: DryRunState['storage']) {}
}

type Action =
  | ChangeEntrypointAction
  | ChangeParametersAction
  | ChangeStorageAction
  | ChangeSelectedExampleAction
  | ChangeProtocolAction;

const DEFAULT_STATE: DryRunState = {
  entrypoint: '',
  parameters: '',
  storage: '',
  protocol: 'kathmandu'
};

export const dryRun = (state = DEFAULT_STATE, action: Action): DryRunState => {
  switch (action.type) {
    case ExamplesActionType.ChangeSelected:
      return {
        ...state,
        ...(!action.payload ? DEFAULT_STATE : action.payload.dryRun)
      };
    case ActionType.ChangeEntrypoint:
      return {
        ...state,
        entrypoint: action.payload
      };
    case ActionType.ChangeProtocol:
      return {
        ...state,
        protocol: action.payload
      };
    case ActionType.ChangeParameters:
      return {
        ...state,
        parameters: action.payload
      };
    case ActionType.ChangeStorage:
      return {
        ...state,
        storage: action.payload
      };
    default:
      return state;
  }
};

// export default DryRun
