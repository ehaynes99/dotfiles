import QtQuick
import Quickshell
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    function pad(n) {
        return String(n).padStart(2, '0');
    }

    function clockText(date) {
        if (!date)
            return "";
        const hours = date.getHours();
        const minutes = pad(date.getMinutes());
        const displayHour = hours === 0 ? 12 : (hours > 12 ? hours - 12 : hours);
        const ampm = hours >= 12 ? "PM" : "AM";
        const local24 = pad(hours) + ":" + minutes;
        const utc24 = pad(date.getUTCHours()) + ":" + pad(date.getUTCMinutes());
        return displayHour + ":" + minutes + " " + ampm + " (" + local24 + " - " + utc24 + " UTC)";
    }

    function dateText(date) {
        if (!date)
            return "";
        return date.toLocaleDateString(I18n.locale(), "ddd MMM d");
    }

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    pillClickAction: (x, y, width, section, screen) => {
        PopoutService.toggleDankDash("overview", x, y, width, section, screen);
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.clockText(systemClock.date)
                color: Theme.widgetTextColor
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: "•"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.outlineButton
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.dateText(systemClock.date)
                color: Theme.widgetTextColor
                font.pixelSize: Theme.barTextSize(root.barThickness, root.barConfig?.fontScale, root.barConfig?.maximizeWidgetText)
            }
        }
    }
}
