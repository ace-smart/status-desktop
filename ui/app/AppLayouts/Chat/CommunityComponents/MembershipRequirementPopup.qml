import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    height: 480

    title: qsTr("Membership requirement")

    ScrollView {
        property ScrollBar vScrollBar: ScrollBar.vertical

        id: scrollView
        anchors.fill: parent
        rightPadding: Style.current.bigPadding
        anchors.rightMargin: - Style.current.bigPadding
        leftPadding: Style.current.bigPadding
        anchors.leftMargin: - Style.current.bigPadding
        contentHeight: content.height
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        ButtonGroup {
            id: membershipRequirementGroup
        }

        Column {
            id: content
            width: parent.width
            spacing: Style.current.padding

            MembershipRadioButton {
                text: qsTr("Require approval")
                description: qsTr("Your community is free to join, but new members are required to be approved by the community creator first")
                buttonGroup: membershipRequirementGroup
            }

            MembershipRadioButton {
                text: qsTr("Require invite from another member")
                description: qsTr("Your community can only be joined by an invitation from existing community members")
                buttonGroup: membershipRequirementGroup
            }

            MembershipRadioButton {
                text: qsTr("Require ENS username")
                description: qsTr("Your community requires an ENS username to be able to join")
                buttonGroup: membershipRequirementGroup
            }

            MembershipRadioButton {
                text: qsTr("No requirement")
                description: qsTr("Your community is free for anyone to join")
                buttonGroup: membershipRequirementGroup
            }
        }
    }

    footer: StatusButton {
        text: qsTr("Create")
        anchors.right: parent.right
        onClicked: {
            if (!validate()) {
                scrollView.scrollBackUp()
                return
            }
            const error = chatsModel.createCommunityChannel(communityId,
                                                            Utils.filterXSS(nameInput.text),
                                                            Utils.filterXSS(descriptionTextArea.text))

            if (error) {
                creatingError.text = error
                return creatingError.open()
            }

            // TODO Open the community once we have designs for it
            popup.close()
        }

        MessageDialog {
            id: creatingError
            title: qsTr("Error creating the community")
            icon: StandardIcon.Critical
            standardButtons: StandardButton.Ok
        }
    }
}

