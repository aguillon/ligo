import React, { PureComponent } from "react";

import { Modal, DebouncedFormGroup } from "~/base-components/ui-components";
import { validName } from "~/components/validators";

import actions from "../actions";

export default class RenameProjectModal extends PureComponent {
  constructor(props) {
    super(props);

    this.state = {
      newName: "",
      name: "",
      creating: false,
    };

    this.modal = React.createRef();

    actions.renameProjectModal = this;
  }

  openModal(project) {
    const { defaultTemplate } = this.props;
    this.setState({
      creating: false,
      name: project.name,
      newName: project.name,
    });
    // this.forceUpdate();
    this.modal.current.openModal();
    return new Promise((resolve) => {
      this.onConfirm = resolve;
    });
  }

  onRenameProject = () => {
    this.setState({ creating: true });

    const { newName } = this.state;

    this.onConfirm(newName);
    this.modal.current.closeModal();

    this.setState({
      name: "",
      newName: "",
      creating: false,
    });
  };

  render() {
    const { newName, name, creating } = this.state;

    return (
      <Modal
        ref={this.modal}
        title="Rename Project"
        textConfirm="Rename"
        onConfirm={this.onRenameProject}
        pending={creating && "Renaming..."}
        confirmDisabled={!newName || !!validName(newName)}
      >
        <DebouncedFormGroup
          label={
            <div>
              New name for <kbd>{this.state.name}</kbd>
            </div>
          }
          value={newName}
          onChange={(newName) => this.setState({ newName })}
          validator={validName}
        />
      </Modal>
    );
  }
}
