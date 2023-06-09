/* eslint-disable @typescript-eslint/no-unsafe-member-access,@typescript-eslint/no-unsafe-call */
/* eslint-disable react/destructuring-assignment */
/* eslint-disable @typescript-eslint/no-unsafe-assignment */
/* eslint-disable new-cap */
import { lazy, useEffect, useRef, useState } from "react";
import { GlobalHotKeys } from "react-hotkeys";
import { GlobalModals, autoUpdater } from "~/base-components/global";
import { config, updateStore } from "~/lib/redux";
import redux, { Provider } from "~/base-components/redux";

import { LoadingScreen } from "~/base-components/ui-components";
import { NotificationSystem } from "~/base-components/notification";
import Routes from "./components/Routes";
import fileOps, { indexedDBFileSystem, fileSystems, fileSystem } from "~/base-components/file-ops";
import icon from "./components/icon.png";
import { ProjectManager, actions } from "~/base-components/workspace";
import LigoHeader from "~/components/LigoHeader";

// eslint-disable-next-line @typescript-eslint/ban-ts-comment
// @ts-ignore
const Header = lazy(() => import("./components/Header" /* webpackChunkName: "header" */));
const BottomBar = lazy(() => import("./components/BottomBar" /* webpackChunkName: "bottombar" */));

const ReduxApp = (props: { history: any }) => {
  const [loaded, setLoaded] = useState(false);
  const ligoIdeFileSystems = useRef<fileSystems>(new fileSystems());
  const indexedDB = useRef<fileSystem>(new indexedDBFileSystem());
  const bottomBarRef = useRef<typeof BottomBar>(null);

  useEffect(() => {
    async function loadStorage() {
      await redux.init(config, updateStore);
      await ligoIdeFileSystems.current.addFileSystem(indexedDB.current);
      ligoIdeFileSystems.current.setFileSystem([indexedDB.current]);
      if (!(await fileOps.exists(".workspaces/default-project"))) {
        const Manager = ProjectManager;
        const defaultProject = await Manager.createProject("default-project", "increment", "ligo");
        redux.dispatch("ADD_PROJECT", {
          type: "local",
          project: defaultProject,
        });
      }
      // TODO in case of any changes in fs we should be able to migrate data
      setLoaded(true);
      autoUpdater.check();
    }
    // eslint-disable-next-line @typescript-eslint/no-floating-promises
    loadStorage();
  }, []);

  if (!loaded) {
    // eslint-disable-next-line @typescript-eslint/ban-ts-comment
    // @ts-ignore
    return <LoadingScreen />;
  }

  return (
    <Provider store={redux.store}>
      <div className="body">
        <LigoHeader />
        <Header history={props.history} />
        <NotificationSystem />
        <GlobalModals icon={icon} />
        <GlobalHotKeys
          keyMap={{ CtrlCmdB: ["command+b", "control+b"] }}
          handlers={{
            CtrlCmdB: () => {
              if (actions.projectManager !== null) {
                actions.projectManager.compile(null, undefined);
              }
            },
          }}
        />
        <Routes />
        <BottomBar ref={bottomBarRef} />
      </div>
    </Provider>
  );
};

export default ReduxApp;
