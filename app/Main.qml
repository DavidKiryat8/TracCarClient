import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import QtPositioning 5.2
import QtQuick.LocalStorage 2.0

MainView {


    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "traccarclient.kiryat8"

    width: units.gu(100)
    height: units.gu(75)


    QtObject {
            id: tracReading
            property string url
            property string port
            property int    interval_minutes
            property int    deviceid
            property int    count
            property int    minutes;
            property int battery
            property int timestamp
            property real lat
            property real lon
            property real speed
            property real bearing
            property real altitude
        }
     // property string currentSubreddit: ""

     Component{
         id: settingsSaveComponent
       Dialog {
         id: configSaveDialog
         title: "Configuration has been saved"
         text: "Your configuration has been saved"
         Button {
             text: "OK"
             color: UbuntuColors.green
             onClicked: PopupUtils.close(configSaveDialog)
         }

       }
     }
     Component{
      id: settingsComponent
       Dialog {
         id: dialog
         title: "Configuration"
         text: "Set a new Configuration"
         TextField {
                 placeholderText: "DeviceID"
                 id: cDeviceID
                 text: tracReading.deviceid
                 validator: IntValidator{bottom: 1;}
                 inputMethodHints: Qt.ImhDigitsOnly
                 color: "black"
                 // parseInt(text,10)
                 onTextChanged: {if (text!=null) console.log(text)}
         }
         TextField {
                 placeholderText: "Server URL"
                 id: cURL
                 text: tracReading.url
                 inputMethodHints: Qt.ImhUrlCharactersOnly
                 color: "black"
                 onTextChanged: {if (text!=null) console.log(text)}
         }
         TextField {
                 placeholderText: "Server Port"
                 id: cPort
                 text: tracReading.port
                 validator: IntValidator{bottom: 80; top: 65535;}
                 inputMethodHints: Qt.ImhDigitsOnly
                 color: "black"
                 onTextChanged: {if (text!=null) console.log(text)}
         }
         TextField {
                 placeholderText: "Interval Minutes"
                 id: cInterval
                 text: tracReading.interval_minutes
                 validator: IntValidator{bottom: 4; top: 65535;}
                 inputMethodHints: Qt.ImhDigitsOnly
                 color: "black"
                 onTextChanged: {if (text!=null) console.log(text)}
         }
         Button {
             text: "save configuration"
             color: UbuntuColors.ash
             onClicked:{
                 // validate fields
                 if (cURL.text.length===0 || cDeviceID.text.length===0 ||
                     cPort.text.length===0 || cInterval.text.length===0){
//    ?!?
                 }else{
                         tracReading.deviceid = parseInt(cDeviceID.text,10)
                         tracReading.url      = cURL.text
                         tracReading.port     = cPort.text
                         tracReading.interval_minutes = parseInt(cInterval.text,10)

                        setConfig()
                        PopupUtils.open(settingsSaveComponent)
                        PopupUtils.close(dialog)
                 }
             }
         }
         Button {
             text: "cancel"
             color: UbuntuColors.orange
             onClicked: PopupUtils.close(dialog)
         }
      }
    }
    Page {
        header: PageHeader {
            id: pageHeader
            title: i18n.tr("TracCarClient")
            /*
            StyleHints {
                foregroundColor: UbuntuColors.orange
                backgroundColor: UbuntuColors.porcelain
                dividerColor: UbuntuColors.slate
            }
            */
            trailingActionBar {
                    actions: [
                        Action {
                            iconName: "settings"
                            text: "first"
                            onTriggered: {
                                PopupUtils.open(settingsComponent)
                            }
                        },
                        Action {
                            iconName: "info"
                            text: "second"
                        },
                        Action {
                            iconName: "search"
                            text: "third"
                        }
                   ]
                   numberOfSlots: 2
            }
        }
        Label {
            id: label
            objectName: "label"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: pageHeader.bottom
                topMargin: units.gu(2)
            }

            text: "Coordinate: xx:xx";
        }
/*
        Alarm{
            id: alarm
            onStatusChanged: {
                if (status !== Alarm.Ready)
                  return;
                if ((operation > Alarm.NoOperation) && (operation < Alarm.Reseting)) {
                    request();
                    reset();
                    date = addMinutes(new Date(), tracReading.interval_minutes)
                    save();
                }
            }
        }
*/
        PositionSource {
            id: src

            updateInterval: 1000
            active: true


            onPositionChanged: {

                var coord = src.position.coordinate;
                // Exit if NaN
                if (coord.latitude !=coord.latitude){
                    return
                }
                updateInterval: 10000
                // tracReading.deviceid = 374483
                tracReading.battery = 100.0 // TBD read from phone ?!?

                tracReading.lat= coord.longitude;
                tracReading.lon= coord.latitude;
                if (src.position.speedValid)
                    tracReading.speed= src.position.speed
                else
                    tracReading.speed= 0.0
                if (src.position.directionValid)
                    tracReading.bearing= src.position.direction
                else
                    tracReading.bearing= 0
                if (src.position.altitudeValid)
                    tracReading.altitude= src.position.coordinate.altitude
                else
                    tracReading.altitude= 0.0
                tracReading.timestamp= 1468576736;// QTime(0,0).msecsTo(src.position.timestamp.time());


                // Math.round(33.088117576394794 * 100) / 100; instead of slow toFixed
                label.text = "Coordinate: " + coord.longitude.toFixed(4) + ":" +
                                      coord.latitude.toFixed(4);
                console.log("Coordinate: " + coord.longitude + ":" + coord.latitude);

                // Count 10seconds
                tracReading.count++;
                // Count minutes
                if (tracReading.count>=6){
                    tracReading.count = 0
                    tracReading.minutes++
                    if (tracReading.minutes>=tracReading.interval_minutes){
                        tracReading.minutes = 0
                        request();
                    }
                }

            }
        }

        Rectangle {
            id: rectStatus
            color: UbuntuColors.silk
            width: (parent.width/2)+20
            height: units.gu(6)
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: label.bottom
                topMargin: units.gu(2)
            }
            Rectangle {
             width: (parent.width-40)
             height: units.gu(4)
             anchors {
                 horizontalCenter: parent.horizontalCenter
                 verticalCenter:   parent.verticalCenter
             }
              Label {
                 id: labelStatus
                 anchors.centerIn: parent
                 text: ""
                 fontSize: "large"
              }
            }
        }
        Button {
            id: buttonGet
            objectName: "button"
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: rectStatus.bottom
                topMargin: units.gu(2)
            }
            width: parent.width
            text: i18n.tr("Send Coordinates!")
            onClicked: {
                labelStatus.text = i18n.tr("Sending...")
                rectStatus.color = UbuntuColors.coolGrey;
                request();
            }
        }
        Component.onCompleted: setup()

    }

    function setup(){
        // defaults
        tracReading.deviceid = 374483
        tracReading.url      = "http://kiryat8.com"
        tracReading.port     = 5055
        tracReading.interval_minutes = 15
        tracReading.minutes  = 0;
        tracReading.count    = 0;
        // Get Configuration rom database
        getConfig();
 //       alarm.date = addMinutes(new Date(), tracReading.interval_minutes)
 //       alarm.save();
    }

    function addMinutes(date, minutes) {
        return new Date(date.getTime() + minutes*60000);
    }

    function sprintf() {
        var args = arguments,
        string = args[0],
        i = 1;
        return string.replace(/%((%)|s|d|f)/g, function (m) {
            // m is the matched format, e.g. %s, %d
            var val = null;
            if (m[2]) {
                val = m[2];
            } else {
                val = args[i];
                // A switch statement so that the formatter can be extended. Default is %s
                switch (m) {
                    case '%d':
                    case '%f':
                        val = parseFloat(val);
                        if (isNaN(val)) {
                            val = 0;
                        }
                        break;
                }
                i++;
            }
            return val;
        });
    }

    function getConfig() {
        var db = LocalStorage.openDatabaseSync(applicationName,"1.0", "TracCarClientConfig",1000);

        db.transaction(
            function(tx) {
                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS Config(label TEXT, val TEXT)');

                // Get all added configuration lines
                var rs = tx.executeSql('SELECT * FROM Config');

                if (rs.rows.length<=0){
                    // Add
                    tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'u',tracReading.url]);
                    // Add
                    tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'p',tracReading.port]);
                    // Add
                    tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'i',tracReading.interval_minutes]);
                    // Add
                    tx.executeSql('INSERT INTO Config VALUES(?, ?)', [ 'd',tracReading.deviceid]);
                    return;
                }

                // var r = ""
                for(var i = 0; i < rs.rows.length; i++) {
                    switch (rs.rows.item(i).label){
                    case 'u':
                          tracReading.url = rs.rows.item(i).val
                          break
                    case 'p':
                          tracReading.port = rs.rows.item(i).val
                          break
                    case 'i':
                          tracReading.interval_minutes = rs.rows.item(i).val
                          break
                    case 'd':
                          tracReading.deviceid = rs.rows.item(i).val
                          break

                    } // switch
                }
            }
        )
    } // getConfig

    function setConfig() {
        var db = LocalStorage.openDatabaseSync(applicationName,"1.0", "TracCarClientConfig",1000);

        db.transaction(
            function(tx) {

  //   tx.executeSql('DELETE FROM Config');

                // Create the database if it doesn't already exist
                tx.executeSql('CREATE TABLE IF NOT EXISTS Config(label TEXT, val TEXT)');

                // Add
                tx.executeSql('UPDATE Config SET label=?,val=?',['u',tracReading.url]);

                // Add
                tx.executeSql('UPDATE Config SET label=?,val=?',['p',tracReading.port]);
                // Add
                tx.executeSql('UPDATE Config SET label=?,val=?',['i',tracReading.interval_minutes]);
                // Add
                tx.executeSql('UPDATE Config SET label=?,val=?',['d',tracReading.deviceid]);
            }
        )
    } // setConfig

    function toHex(str) {
        var hex = '';
        for(var i=0;i<str.length;i++) {
            hex += ''+str.charCodeAt(i).toString(16);
        }
        return hex;
    } // toHex

    function pad(num, size) {
        var s = num+"";
        while (s.length < size) s = "0" + s;
        return s;
    }

    function formatData() {

    } // formatData

    function request() {
        var sF = [
                    "?id=",
                    "&timestamp=",
                    "&lat=",
                    "&lon=",
                    "&speed=",
                    "&bearing=",
                    "&altitude=",
                    "&batt="
                ];
        var xhr = new XMLHttpRequest();
        // "http://kiryat8.com:5055";
        var url = tracReading.url + ':' + tracReading.port;

        var str = sF[0] + tracReading.deviceid
                str = str + sF[1] + tracReading.timestamp
                str = str + sF[2] + tracReading.lat
                str = str + sF[3] + tracReading.lon
                str = str + sF[4] + tracReading.speed
                str = str + sF[5] + tracReading.bearing
                str = str + sF[6] + tracReading.altitude
                str = str + sF[7] + tracReading.battery + " HTTP/1.1 200 "
        var params =  str + str.length + " ";

        xhr.open("GET", url+params, true);

        xhr.onreadystatechange = function() {
            if (xhr.readyState === xhr.HEADERS_RECEIVED) {
                print('HEADERS_RECEIVED')
            }else
            if (xhr.readyState === xhr.DONE) {
                // TBD Eror checking returns status=0 good or not
                if (xhr.status===200){
                  rectStatus.color = UbuntuColors.green
                  labelStatus.text = i18n.tr("Sent!")
                }else{
                    rectStatus.color = UbuntuColors.red
                    labelStatus.text = i18n.tr("Failure:"+xhr.status)
                }

                print('DONE')

            }

        }
        xhr.onerror = function () {
            rectStatus.color = UbuntuColors.red
            labelStatus.text = i18n.tr("Failure:"+xhr.status)
        };
        // Send with data appended to URL
        xhr.send();
    }
}


