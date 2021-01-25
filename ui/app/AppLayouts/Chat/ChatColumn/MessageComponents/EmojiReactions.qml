import QtQuick 2.3
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../../../imports"

Item {
    property int imageMargin: 4
    signal hoverChanged(bool hovered)

    id: root
    height: 20
    width: childrenRect.width

    function lastTwoItems(nodes) {
        return nodes.join(qsTr(" and "));
    }

    function showReactionAuthors(fromAccounts) {
        if (fromAccounts.length < 3)
            return lastTwoItems(fromAccounts);

        var leftNode = [];
        var rightNode = [];

        if (fromAccounts.length > 3) {
            leftNode = fromAccounts.slice(0, 3);
            rightNode = fromAccounts.slice(3, fromAccounts.length);
            return (rightNode.length === 1) ?
                                lastTwoItems([leftNode.join(", "), rightNode[0]]) :
                                lastTwoItems([leftNode.join(", "), qsTr("%1 more reacted.").arg(rightNode.length)]);
        }

        leftNode = fromAccounts.slice(0, 2);
        rightNode = fromAccounts.slice(2, fromAccounts.length);
        return lastTwoItems([leftNode.join(", "), rightNode[0]]);
    }

    Row {
        spacing: root.imageMargin

        Repeater {
            id: reactionRepeater
            width: childrenRect.width
            model: {
                if (!emojiReactions) {
                    return []
                }

                try {
                    // group by id
                    var allReactions = Object.values(JSON.parse(emojiReactions))
                    var byEmoji = {}
                    allReactions.forEach(function (reaction) {
                        if (!byEmoji[reaction.emojiId]) {
                            byEmoji[reaction.emojiId] = {
                                emojiId: reaction.emojiId,
                                fromAccounts: [],
                                count: 0,
                                currentUserReacted: false
                            }
                        }
                        byEmoji[reaction.emojiId].count++;
                        byEmoji[reaction.emojiId].fromAccounts.push(chatsModel.userNameOrAlias(reaction.from));
                        if (!byEmoji[reaction.emojiId].currentUserReacted && reaction.from === profileModel.profile.pubKey) {
                            byEmoji[reaction.emojiId].currentUserReacted = true
                        }

                    })
                    return Object.values(byEmoji)
                } catch (e) {
                    console.error('Error parsing emoji reactions', e)
                    return []
                }

            }

            Rectangle {
                property bool isHovered: false

                id: emojiContainer
                width: emojiImage.width + emojiCount.width + (root.imageMargin * 2) +  + 8
                height: 20
                radius: 10
                color: modelData.currentUserReacted ? Style.current.secondaryBackground :
                                                      (isHovered ? Style.current.emojiReactionBackgroundHovered : Style.current.emojiReactionBackground)

                ToolTip {
                    visible: mouseArea.containsMouse
                    text: showReactionAuthors(modelData.fromAccounts)
                }

                // Rounded corner to cover one corner
                Rectangle {
                    color: parent.color
                    width: 8
                    height: 8
                    anchors.top: parent.top
                    anchors.left: !isCurrentUser || appSettings.compactMode ? parent.left : undefined
                    anchors.leftMargin: 0
                    anchors.right: !isCurrentUser || appSettings.compactMode ? undefined : parent.right
                    anchors.rightMargin: 0
                    radius: 2
                    z: -1
                }

                // This is a workaround to get a "border" around the rectangle including the weird rectangle
                Loader {
                    active: modelData.currentUserReacted
                    anchors.top: parent.top
                    anchors.topMargin: -1
                    anchors.left: parent.left
                    anchors.leftMargin: -1
                    z: -2

                    sourceComponent: Component {
                        Rectangle {
                            width: emojiContainer.width + 2
                            height: emojiContainer.height + 2
                            radius: emojiContainer.radius
                            color: Style.current.primary

                            Rectangle {
                                color: parent.color
                                width: 8
                                height: 8
                                anchors.top: parent.top
                                anchors.left: !isCurrentUser || appSettings.compactMode ? parent.left : undefined
                                anchors.leftMargin: 0
                                anchors.right: !isCurrentUser || appSettings.compactMode ? undefined : parent.right
                                anchors.rightMargin: 0
                                radius: 2
                                z: -1
                            }
                        }
                    }
                }

                SVGImage {
                    id: emojiImage
                    width: 15
                    fillMode: Image.PreserveAspectFit
                    source: {
                        const basePath = "../../../../img/emojiReactions/"
                        switch (modelData.emojiId) {
                        case 1: return basePath + "heart.svg"
                        case 2: return basePath + "thumbsUp.svg"
                        case 3: return basePath + "thumbsDown.svg"
                        case 4: return basePath + "laughing.svg"
                        case 5: return basePath + "sad.svg"
                        case 6: return basePath + "angry.svg"
                        default: return ""
                        }
                    }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: root.imageMargin
                }

                StyledText {
                    id: emojiCount
                    text: modelData.count
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: emojiImage.right
                    anchors.leftMargin: root.imageMargin
                    font.pixelSize: 12
                    color: modelData.currentUserReacted ? Style.current.textColorTertiary : Style.current.textColor
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        root.hoverChanged(true)
                        emojiContainer.isHovered = true
                    }
                    onExited: {
                        root.hoverChanged(false)
                        emojiContainer.isHovered = false
                    }
                    onClicked: {
                        chatsModel.toggleReaction(messageId, modelData.emojiId)

                    }
                }
            }
        }

        Item {
            width: addEmojiBtn.width + addEmojiBtn.anchors.leftMargin // there is more margin between the button and the emojis than between each emoji
            height: addEmojiBtn.height

            SVGImage {
                property bool isHovered: false

                id: addEmojiBtn
                source: "../../../../img/emoji.svg"
                width: 16.5
                height: 16.5
                anchors.left: parent.left
                anchors.leftMargin: 2.5

            }

            ColorOverlay {
                anchors.fill: addEmojiBtn
                antialiasing: true
                source: addEmojiBtn
                color: addEmojiBtn.isHovered ? Style.current.primary : Style.current.secondaryText
            }

            MouseArea {
                anchors.fill: addEmojiBtn
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: addEmojiBtn.isHovered = true
                onExited: addEmojiBtn.isHovered = false
                onClicked: {
                    isMessageActive = true
                    clickMessage(false, false, false, null, true)
                }
            }

            StatusToolTip {
              visible: addEmojiBtn.isHovered
              text: qsTr("Add reaction")
              width: 115
            }
        }
    }
}
