module app;

import std.file : getcwd;
import std.string : toStringz;
import std.stdio : writefln;

import libnotify;

void callback(NotifyNotification* notification, char* action, void* user_data)
{
	writefln("Hello?");
}

void main()
{
	notify_init("application");

	auto simple_notify = notify_notification_new("Simple Notify", "Here some text", null);
	notify_notification_show(simple_notify, null);

	auto icon_notify = notify_notification_new("Notify with icon", "Here some text. Also cool icon here!", (getcwd() ~ "/icon.png").toStringz);
	notify_notification_show(icon_notify, null);

	auto action_notify = notify_notification_new("Notify with button", "But callback will not work", null);
	notify_notification_add_action(action_notify, "close", "Close", &callback, null, null);
	notify_notification_show(action_notify, null);

	auto critical_notify = notify_notification_new("Critical notify", "It will last forever", null);
	notify_notification_set_urgency(critical_notify, NotifyUrgency.CRITICAL);
	notify_notification_show(critical_notify, null);
}