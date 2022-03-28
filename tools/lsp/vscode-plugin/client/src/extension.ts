/* --------------------------------------------------------------------------------------------
 * Copyright (c) Microsoft Corporation. All rights reserved.
 * Licensed under the MIT License. See License.txt in the project root for license information.
 * ------------------------------------------------------------------------------------------ */

import * as vscode from 'vscode';
import { extname } from 'path';
import {
  LanguageClient,
  LanguageClientOptions,
  ServerOptions,
} from 'vscode-languageclient/node';

import { registerCommands } from './command'
import { initializeExtensionState } from './ui'
import updateExtension from './updateExtension'
import updateLigo from './updateLigo'

let client: LanguageClient;
let optionButton: vscode.StatusBarItem;

// Hides compilation button in case current active text editor is not .(m/re)ligo file
// If currently active text window is not an opened file (terminal, explorer, etc.)
// button will remain in it's previous state
function updateLigoButton() {
  const path = vscode.window.activeTextEditor.document.uri.fsPath;
  const ext = extname(path);

  // Ignore vscode windows
  if (path.startsWith('extension')) {
    return;
  }

  if (ext === '.ligo' || ext === '.mligo' || ext === '.religo') {
    optionButton.show();
  } else {
    optionButton.hide();
  }
}

export async function activate(context: vscode.ExtensionContext) {
  if (context.extensionMode === vscode.ExtensionMode.Production) {
    await updateLigo()
    await updateExtension(context)
  }

  const serverOptions: ServerOptions = {
    command: `${context.extensionPath}/bin/ligo-squirrel`,
    options: {
      cwd: `${context.extensionPath}`,
    },
  };

  // This section adds 'LIGO Options' status bar button,
  // which allows to execute different ligo commands from inside the extension.

  initializeExtensionState();

  const optionCommandId = 'ligo.chooseOption';
  optionButton = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 0);
  optionButton.command = optionCommandId;
  optionButton.text = 'LIGO Options';
  optionButton.tooltip = 'Display LIGO options';
  context.subscriptions.push(optionButton);

  context.subscriptions.push(vscode.window.onDidChangeActiveTextEditor(updateLigoButton));
  context.subscriptions.push(vscode.window.onDidChangeTextEditorSelection(updateLigoButton));
  updateLigoButton();

  // Options to control the language client
  const clientOptions: LanguageClientOptions = {
    // Register the server for plain text documents
    documentSelector: [
      { scheme: 'file', language: 'ligo' },
      { scheme: 'file', language: 'mligo' },
      { scheme: 'file', language: 'religo' },
    ],
    synchronize: {
      // Notify the server about file changes to '.clientrc files contained in the workspace
      // fileEvents: workspace.createFileSystemWatcher('**/.clientrc')
    },
  };

  // Create the language client and start the client.
  client = new LanguageClient(
    'ligoLanguageServer',
    'LIGO Language Server',
    serverOptions,
    clientOptions,
  );

  // Register VSC-specific server commands
  registerCommands(client);

  // Start the client. This will also launch the server
  client.start();
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) {
    return undefined;
  }
  return client.stop();
}
