import React from "react";

import { SplitPane } from "~/base-components/ui-components";

import { NodeTerminal } from "~/ligo-components/eth-node";
import InstanceList from "./InstanceList";

export default function LocalNetwork(props) {
  const { active, networkId, configButton, minerKey, tabs } = props;
  return (
    <SplitPane split="horizontal" primary="second" defaultSize={260} minSize={200}>
      <InstanceList networkId={networkId} configButton={configButton} minerKey={minerKey} />
      <NodeTerminal active={active} {...tabs} />
    </SplitPane>
  );
}
