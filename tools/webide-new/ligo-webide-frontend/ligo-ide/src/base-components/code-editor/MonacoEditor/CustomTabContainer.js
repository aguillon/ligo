import React from "react";

import { LoadingScreen } from "~/base-components/ui-components";

export default function ({ loading, modelSession }) {
  if (loading) {
    return (
      <div className="custom-tab bg2">
        <LoadingScreen />
      </div>
    );
  }
  if (!modelSession.CustomTab) {
    return null;
  }
  return <modelSession.CustomTab modelSession={modelSession} />;
}
