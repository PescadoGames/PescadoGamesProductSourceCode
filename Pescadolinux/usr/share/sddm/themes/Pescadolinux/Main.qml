/***************************************************************************
* Copyright (c) 2013 Abdurrahman AVCI <abdurrahmanavci@gmail.com>
*
* Permission is hereby granted, free of charge, to any person
* obtaining a copy of this software and associated documentation
* files (the "Software"), to deal in the Software without restriction,
* including without limitation the rights to use, copy, modify, merge,
* publish, distribute, sublicense, and/or sell copies of the Software,
* and to permit persons to whom the Software is furnished to do so,
* subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included
* in all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
* OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
* OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
* ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
* OR OTHER DEALINGS IN THE SOFTWARE.
*
***************************************************************************/

import QtQuick 2.3
import QtGraphicalEffects 1.12
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2
import SddmComponents 2.0

Rectangle {
    id: container
    width: 640
    height: 480

    LayoutMirroring.enabled: Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    property int sessionIndex: session.index

    TextConstants { id: textConstants }

    Connections {
        target: sddm

        onLoginSucceeded: {
            errorMessage.color = "steelblue"
            errorMessage.text = textConstants.loginSucceeded
        }

        onLoginFailed: {
            password.text = ""
            errorMessage.color = "red"
            errorMessage.text = textConstants.loginFailed
        }
        onInformationMessage: {
            errorMessage.color = "red"
            errorMessage.text = message
        }
    }

    Background {
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: {
            if (status == Image.Error && source != config.defaultBackground) {
                source = config.defaultBackground
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        //visible: primaryScreen

        Clock {
            id: clock
            anchors.margins: 5
            anchors.top: parent.top; anchors.right: parent.right

            color: "white"
            timeFont.family: "Oxygen"
        }

        Rectangle {
            id: rectangle
            anchors.centerIn: parent
            width: Math.max(320, mainColumn.implicitWidth + 50)
            height: Math.max(320, mainColumn.implicitHeight + 50)
            
            color: "#191919"
            border.width: 0
            radius: 10
            
            layer.enabled: true
            layer.effect: DropShadow {
                transparentBorder: true
                horizontalOffset: 4
                verticalOffset: 4
                radius: 12
                samples: 18
                color: "#181818"
               }
            
            Column {
                id: mainColumn
                anchors.centerIn: parent
                spacing: 12
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    height: text.implicitHeight
                    width: parent.width
                    text: textConstants.welcomeText.arg(sddm.hostName)
                    wrapMode: Text.WordWrap
                    font.pixelSize: 24
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }

                Column {
                    width: parent.width
                    spacing: 4
                    Text {
                        id: lblName
                        color: "white"
                        width: parent.width
                        text: textConstants.userName
                        font.bold: true
                        font.pixelSize: 12
                    }

                    TextBox {
                        id: name
                        width: parent.width; height: 30
                        text: userModel.lastUser
                        font.pixelSize: 14

                        KeyNavigation.backtab: rebootButton; KeyNavigation.tab: password

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Column {
                    width: parent.width
                    spacing : 4
                    Text {
                        id: lblPassword
                        color: "white"
                        width: parent.width
                        text: textConstants.password
                        font.bold: true
                        font.pixelSize: 12
                    }

                    PasswordBox {
                        id: password
                        width: parent.width; height: 30
                        font.pixelSize: 14

                        KeyNavigation.backtab: name; KeyNavigation.tab: session

                        Keys.onPressed: {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                sddm.login(name.text, password.text, sessionIndex)
                                event.accepted = true
                            }
                        }
                    }
                }

                Row {
                    spacing: 4
                    width: parent.width / 2
                    z: 100

                    Column {
                        z: 100
                        width: parent.width * 1.3
                        spacing : 4
                        anchors.bottom: parent.bottom

                        Text {
                            id: lblSession
                            color: "white"
                            width: parent.width
                            text: textConstants.session
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            font.pixelSize: 12
                        }

                        ComboBox {
                            id: session
                            width: parent.width; height: 30
                            font.pixelSize: 14

                            arrowIcon: "angle-down.png"

                            model: sessionModel
                            index: sessionModel.lastIndex

                            KeyNavigation.backtab: password; KeyNavigation.tab: layoutBox
                        }
                    }

                    Column {
                        z: 101
                        width: parent.width * 0.7
                        spacing : 4
                        anchors.bottom: parent.bottom

                        Text {
                            id: lblLayout
                            width: parent.width
                            color: "white"
                            text: textConstants.layout
                            wrapMode: TextEdit.WordWrap
                            font.bold: true
                            font.pixelSize: 12
                        }

                        LayoutBox {
                            id: layoutBox
                            width: parent.width; height: 30
                            font.pixelSize: 14

                            arrowIcon: "angle-down.png"

                            KeyNavigation.backtab: session; KeyNavigation.tab: loginButton
                        }
                    }
                }

                Column {
                    width: parent.width
                    Text {
                        id: errorMessage
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: textConstants.prompt
                        font.pixelSize: 10
                        color: "white"
                    }
                }

                Row {
                    spacing: 4
                    anchors.horizontalCenter: parent.horizontalCenter
                    property int btnWidth: Math.max(loginButton.implicitWidth,
                                                    shutdownButton.implicitWidth,
                                                    rebootButton.implicitWidth, 80) + 8
                    Item {
                    id: loginButton
                    width: parent.btnWidth * 1.7
                    height: 30
                    property alias text: buttontext
                    Rectangle
                         {
                         id: loginbuttonbackground
                         anchors.fill: parent
                         color: "#0167E3"
                         }

                    
                    Image {
                    id: visualImage
                    width: 20
                    height: 20
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter 
                    source: "login.svg"
                          }
                          
                    Text {
                    id: buttontext
                    anchors.rightMargin: parent.width * 0.1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter 
                    font.bold: true
                    text: textConstants.login
                    color: "#fff"
                         }
                         
                    MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                    sddm.login(name.text, password.text, sessionIndex)
                          }
                     onEntered: loginbuttonbackground.color = '#0071FB'
                     onExited: loginbuttonbackground.color = '#0167E3' 
                     onPressed: loginbuttonbackground.color = '#014AA3' 
                     onReleased: loginbuttonbackground.color = '#0167E3' 
                          }
                          }

                    Item {
                    id: shutdownButton
                    width: parent.btnWidth * 1.5
                    height: 30
                    property alias text: buttontext
                    Rectangle
                         {
                         id: shutdownbuttonbackground
                         anchors.fill: parent
                         color: "#0167E3"
                         }

                    
                    Image {
                    width: 20
                    height: 20
                    anchors.leftMargin: parent.width * 0.03
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter 
                    source: "poweroff.svg"
                          }
                          
                    Text {
                    anchors.rightMargin: parent.width * 0.1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter 
                    font.bold: true
                    text: textConstants.shutdown
                    color: "#fff"
                         }
                         
                    MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                    sddm.powerOff()
                          }
                     onEntered: shutdownbuttonbackground.color = '#0071FB'
                     onExited: shutdownbuttonbackground.color = '#0167E3' 
                     onPressed: shutdownbuttonbackground.color = '#014AA3' 
                     onReleased: shutdownbuttonbackground.color = '#0167E3' 
                          }
                          }

                    Item {
                    id: rebootButton
                    width: parent.btnWidth * 1.5
                    height: 30
                    property alias text: buttontext
                    Rectangle
                         {
                         id: rebootbuttonbackground
                         anchors.fill: parent
                         color: "#0167E3"
                         }

                    
                    Image {
                    width: 20
                    height: 20
                    anchors.leftMargin: parent.width * 0.03
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter 
                    source: "reboot.svg"
                          }
                          
                    Text {
                    anchors.rightMargin: parent.width * 0.1
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter 
                    font.bold: true
                    text: textConstants.reboot
                    color: "#fff"
                         }
                         
                    MouseArea{
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                    sddm.reboot()
                          }
                     onEntered: rebootbuttonbackground.color = '#0071FB'
                     onExited: rebootbuttonbackground.color = '#0167E3' 
                     onPressed: rebootbuttonbackground.color = '#014AA3' 
                     onReleased: rebootbuttonbackground.color = '#0167E3' 
                          }
                          }
                }
            }
        }
    }

    Component.onCompleted: {
        if (name.text == "")
            name.focus = true
        else
            password.focus = true
    }
}

