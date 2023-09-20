module app;

import std.stdio : writefln;
import core.stdc.stdlib : exit;

import gtk.c.functions;
import libnotify;

void callback(NotifyNotification* notification, char* action, void* user_data)
{
	writefln("Pong");
	exit(0);
}

void main()
{
	gtk_init(null, null);
	notify_init("application");

	auto action_notify = notify_notification_new("Notify with button", "And callback works!", null);
	notify_notification_add_action(action_notify, "ping", "Ping", &callback, null, null);
	notify_notification_show(action_notify, null);

	gtk_main();
}