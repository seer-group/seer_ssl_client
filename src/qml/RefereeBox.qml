import QtQuick 2.6
import QtQuick.Layouts 1.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Client.Component 1.0 as Client
Item {
    Client.RefereeBox { id : refereeBox; }
    Timer {
        id:refBoxTimer;
        interval:40;
        running:false;
        repeat:true;
        onTriggered: {
            refereeBox.multicastCommand();
        }
    }
    property int state : Client.GameState.HALTED;
    property bool haltGame : false;
    property bool stopGame : true;
    property bool forceStart : false;
    property bool normalStart : false;
    property bool teamControl : false;
    function getButtonsCommand(index){
        switch(index){
        case Client.RefBoxCommand.HALT:
            state = Client.GameState.HALTED;break;
        case Client.RefBoxCommand.STOP_GAME:
            state = Client.GameState.STOPPED;break;
        case Client.RefBoxCommand.FORCE_START:
        case Client.RefBoxCommand.NORMAL_START:
        case Client.RefBoxCommand.DIRECT_KICK_YELLOW:
        case Client.RefBoxCommand.INDIRECT_KICK_YELLOW:
        case Client.RefBoxCommand.DIRECT_KICK_BLUE:
        case Client.RefBoxCommand.INDIRECT_KICK_BLUE:
            state = Client.GameState.RUNNING;break;
        case Client.RefBoxCommand.TIMEOUT_YELLOW:
            state = Client.GameState.TIMEOUT_YELLOW;break;
        case Client.RefBoxCommand.TIMEOUT_BLUE:
            state = Client.GameState.TIMEOUT_BLUE;break;
        case Client.RefBoxCommand.KICKOFF_YELLOW:
        case Client.RefBoxCommand.KICKOFF_BLUE:
            state = Client.GameState.PREPARE_KICKOFF;break;
        case Client.RefBoxCommand.PENALTY_YELLOW:
        case Client.RefBoxCommand.PENALTY_BLUE:
            state = Client.GameState.PREPARE_PENALTY;break;
        default:
            console.log("RefBox Command ERROR!!!!!!");
            return;
        }
        controlButtons(state);
        refereeBox.changeCommand(index);
    }
    function controlButtons(state){
        function unify(onOff){ haltGame = stopGame = forceStart = normalStart = teamControl = onOff; }
        switch(state){
        case Client.GameState.HALTED:
            unify(false);
            stopGame = true;
            break;
        case Client.GameState.PREPARE_KICKOFF:
        case Client.GameState.PREPARE_PENALTY:
            unify(false);
            normalStart = true;
            break;
        case Client.GameState.RUNNING:
        case Client.GameState.TIMEOUT_BLUE:
        case Client.GameState.TIMEOUT_YELLOW:
            unify(false);
            haltGame = stopGame = true;
            break;
        case Client.GameState.STOPPED:
            unify(true);
            stopGame = normalStart = false;
            break;
        }
    }

//    CheckBox{
//        id:refboxSwitch;
//        style: CheckBoxStyle {
//                  indicator: Rectangle {
//                          implicitWidth: 16
//                          implicitHeight: 16
//                          radius: 3
//                          border.color: control.activeFocus ? "darkblue" : "gray"
//                          border.width: 1
//                          Rectangle {
//                              visible: control.checked
//                              color: "#555"
//                              border.color: "#333"
//                              radius: 1
//                              anchors.margins: 4
//                              anchors.fill: parent
//                          }
//                  }
//              }

//        text:qsTr("Use Referee Box") + translator.emptyString;
//        anchors.top: parent.top;
//        anchors.topMargin: 10;
//        anchors.left: parent.left;
//        anchors.leftMargin: 10;
//        onClicked: {
//            checked ? refBoxTimer.start() : refBoxTimer.stop();
//        }
//    }
    ColumnLayout{
        id : refereeSetting;
        width:parent.width*0.95;
        anchors.top:parent.top;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.margins: 10;
        GroupBox{
            width:parent.width;
            title:qsTr("Referee Setting")+translator.emptyString;
            anchors.horizontalCenter: parent.horizontalCenter;
            property bool visionGetter : false;
            Grid{
                id:refereeInputs;
                columns: 2;
                columnSpacing: 20;
                rowSpacing: 5;
                anchors.horizontalCenter: parent.horizontalCenter;
                verticalItemAlignment: Grid.AlignVCenter;
                horizontalItemAlignment: Grid.AlignLeft;
                width:parent.width;
                Text{
                    id:refereeSettingText;
                    text:qsTr("Address")+translator.emptyString;
                }
                TextField{
                    id:address;
                    text:interaction.getDefaultRefereeAddress();
                    width:parent.width - refereeSettingText.width - parent.columnSpacing;
                }
                Text{
                    text:qsTr("Port")+translator.emptyString;
                }
                TextField{
                    id:port;
                    text:interaction.getDefaultRefereePort();
                    width:parent.width - refereeSettingText.width - parent.columnSpacing;
                }
            }
            Button{
                id:refBoxSwitch;
                text:(refBoxSwitch.refereeSwitch ? qsTr("Stop") : qsTr("Send")) + translator.emptyString;
                width:refereeInputs.width;
                anchors.top: refereeInputs.bottom;
                anchors.topMargin: 10;
                anchors.horizontalCenter: parent.horizontalCenter;
                property bool refereeSwitch: false;
                onClicked: changeState();
                function changeState(){
                    refBoxSwitch.refereeSwitch = !refBoxSwitch.refereeSwitch;
                    run();
                }
                function run(){
                    if(refBoxSwitch.refereeSwitch){
                        refereeInputs.enabled = false;
                        refereeBox.changeSetting(address.text,parseInt(port.text));
                        refBoxTimer.start();
                    }else{
                        refBoxTimer.stop();
                        refereeInputs.enabled = true;
                    }
                }
                Component.onCompleted: run();
            }
        }
    }
    ColumnLayout {
        id : control;
        width:parent.width*0.95;
        anchors.top:refereeSetting.bottom;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.margins: 10;
        spacing: 8;
        enabled: refBoxSwitch.refereeSwitch;
        GroupBox{
            title:qsTr("Control Command") + translator.emptyString;
            width : parent.width;
            Grid{
                width:parent.width;
                rows:4;
                columns:1;
                property int buttonWidth : width/columns;
                Button{
                    property int index : Client.RefBoxCommand.HALT;
                    width:parent.buttonWidth;
                    text:qsTr("Halt") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                    enabled: haltGame;
                }
                Button{
                    property int index : Client.RefBoxCommand.STOP_GAME;
                    width:parent.buttonWidth;
                    text:qsTr("Stop Game") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                    enabled: stopGame;
                }
                Button{
                    property int index : Client.RefBoxCommand.FORCE_START;
                    width:parent.buttonWidth;
                    text:qsTr("Force Start") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                    enabled: forceStart;
                }
                Button{
                    property int index : Client.RefBoxCommand.NORMAL_START;
                    width:parent.buttonWidth;
                    text:qsTr("Normal Start") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                    enabled: normalStart;
                }
            }
        }
        GroupBox{
            title:qsTr("Yellow Team Control") + translator.emptyString;
            width : parent.width;
            enabled: teamControl;
            Grid{
                width:parent.width;
                rows:4;
                columns:1;
                property int buttonWidth : width/columns;
                Grid{
                    width:parent.width;
                    rows:1;
                    columns:2;
                    property int buttonWidth : width/columns;
                    Button{
                        property int index : Client.RefBoxCommand.KICKOFF_YELLOW;
                        width:parent.buttonWidth;
                        text:qsTr("Kick off") + translator.emptyString;
                        onClicked:getButtonsCommand(index);
                    }
                    Button{
                        property int index : Client.RefBoxCommand.PENALTY_YELLOW;
                        width:parent.buttonWidth;
                        text:qsTr("Penalty") + translator.emptyString;
                        onClicked:getButtonsCommand(index);
                    }
                }
                Button{
                    property int index : Client.RefBoxCommand.DIRECT_KICK_YELLOW;
                    width:parent.buttonWidth;
                    text:qsTr("Direct Free Kick") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                }
                Button{
                    property int index : Client.RefBoxCommand.INDIRECT_KICK_YELLOW;
                    width:parent.buttonWidth;
                    text:qsTr("Indirect Free Kick") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                }
                Grid{
                    width:parent.width;
                    rows:1;
                    columns:1;//2;
                    property int buttonWidth : width/columns;
                    Button{
                        property int index : Client.RefBoxCommand.TIMEOUT_YELLOW;
                        width:parent.buttonWidth;
                        text:qsTr("Timeout") + translator.emptyString;
                        onClicked:getButtonsCommand(index);
                    }
                }
            }
        }
        GroupBox{
            title:qsTr("Blue Team Control") + translator.emptyString;
            width : parent.width;
            enabled: teamControl;
            Grid{
                width:parent.width;
                rows:4;
                columns:1;
                property int buttonWidth : width/columns;
                Grid{
                    width:parent.width;
                    rows:1;
                    columns:2;
                    property int buttonWidth : width/columns;
                    Button{
                        property int index : Client.RefBoxCommand.KICKOFF_BLUE;
                        width:parent.buttonWidth;
                        text:qsTr("Kick off") + translator.emptyString;
                        onClicked:getButtonsCommand(index);
                    }
                    Button{
                        property int index : Client.RefBoxCommand.PENALTY_BLUE;
                        width:parent.buttonWidth;
                        text:qsTr("Penalty") + translator.emptyString;
                        onClicked:getButtonsCommand(index);
                    }
                }
                Button{
                    property int index : Client.RefBoxCommand.DIRECT_KICK_BLUE;
                    width:parent.buttonWidth;
                    text:qsTr("Direct Free Kick") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                }
                Button{
                    property int index : Client.RefBoxCommand.INDIRECT_KICK_BLUE;
                    width:parent.buttonWidth;
                    text:qsTr("Indirect Free Kick") + translator.emptyString;
                    onClicked:getButtonsCommand(index);
                }
                Grid{
                    width:parent.width;
                    rows:1;
                    columns:1;//2;
                    property int buttonWidth : width/columns;
                    Button{
                        property int index : Client.RefBoxCommand.TIMEOUT_BLUE;
                        width:parent.buttonWidth;
                        text:qsTr("Timeout") + translator.emptyString;
                        onClicked:getButtonsCommand(index);
                    }
                }
            }
        }
    }
}
