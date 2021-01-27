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

            Item {
                width: parent.width
                height: childrenRect.height

                StatusRadioButtonRow {
                    id: radioBtn
                    text: qsTr("Require ENS username")
                    buttonGroup: membershipRequirementGroup
//                    checked: appSettings.notificationSetting === Constants.notifyAllMessages
                    onRadioCheckedChanged: {
//                        if (checked) {
//                            appSettings.notificationSetting = Constants.notifyAllMessages
//                        }
                    }
                }

                StyledText {
                    id: radioDesc
                    text: qsTr("Your community requires an ENS username to be able to join")
                    anchors.top: radioBtn.bottom
                    anchors.topMargin: Style.current.halfPadding
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 100
                    font.pixelSize: 13
                    color: Style.current.secondaryText
                    wrapMode: Text.WordWrap
                }

                Separator {
                    anchors.top: radioDesc.bottom
                    anchors.topMargin: Style.current.halfPadding
                }
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

