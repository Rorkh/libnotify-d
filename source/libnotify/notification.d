module libnotify.notification;

import glib;
import gobject;

alias NotifyActionCallback = void function(NotifyNotification* notification, char* action, gpointer user_data);

/** 
 * The default expiration time on a notification.
 */
const NOTIFY_EXPIRES_DEFAULT = -1;
/** 
 * The notification never expires. It stays open until closed by the calling API or the user.
 */
const NOTIFY_EXPIRES_NEVER = 0;

extern(C) {
    struct NotifyNotificationPrivate
    {
            guint32 id;
            char* app_name;
            char* summary;
            char* body;
            char* activation_token;

            /* NULL to use icon data. Anything else to have server lookup icon */
            char* icon_name;
            void* icon_pixbuf;

            /*
            * -1   = use server default
            *  0   = never timeout
            *  > 0 = Number of milliseconds before we timeout
            */
            gint timeout;
            guint portal_timeout_id;

            GSList* actions;
            GHashTable* action_map;
            GHashTable* hints;

            gboolean has_nondefault_actions;
            gboolean activating;
            gboolean updates_pending;

            gulong proxy_signal_handler;

            gint closed_reason;
    }


    struct NotifyNotification
    {
        /*< private >*/
        GObject parent_object;
        NotifyNotificationPrivate *priv;
    }

    struct NotifyNotificationClass
    {
        GObjectClass parent_class;
        /* Signals */
        void function(int*) closed;
    }

    /** 
     * The urgency level of the notification.
     */
    enum NotifyUrgency {
        /** Low urgency. Used for unimportant notifications. */
        LOW,
        /** Normal urgency. Used for most standard notifications. */
        NORMAL,
        /** Critical urgency. Used for very important notifications. */
        CRITICAL,
    }

    /** 
     * Creates a new NotifyNotification. The summary text is required, but all other parameters are optional.
     * Params:
     *   summary = The required summary text.
     *   body = The optional body text. 
     *   icon = The optional icon theme icon name or filename. 
     * Returns: The new NotifyNotification.
     */
    NotifyNotification* notify_notification_new(const char* summary, const char* body, const char* icon);
    /** 
     * Updates the notification text and icon. This won't send the update out and display it on the screen. For that, you will need to call notify_notification_show().
     * Params:
     *   notification = The notification to update.
     *   summary = The new required summary text.
     *   body = The optional body text. 
     *   icon = The optional icon theme icon name or filename.
     * Returns: true, unless an invalid parameter was passed.
     */
    gboolean notify_notification_update(NotifyNotification *notification, const char *summary, const char *body, const char *icon);
    /** 
     * Tells the notification server to display the notification on the screen.
     * Params:
     *   notification = The notification. 
     *   error = The returned error information.
     * Returns: true if successful. On error, this will return false and set error.
     */
    gboolean notify_notification_show(NotifyNotification *notification, GError **error);

    /** 
     * Sets the application name for the notification. If this function is not called or if app_name is null, the application name will be set from the value used in notify_init() or overridden with notify_set_app_name().
     * Params:
     *   notification = a NotifyNotification
     *   app_name = the localised application name
     */
    void notify_notification_set_app_name (NotifyNotification* notification, const char* app_name);
    /** 
     * Sets the timeout of the notification. To set the default time, pass NOTIFY_EXPIRES_DEFAULT as timeout . To set the notification to never expire, pass NOTIFY_EXPIRES_NEVER.
     * Params:
     *   notification = The notification.
     *   timeout = The timeout in milliseconds.
     */
    void notify_notification_set_timeout(NotifyNotification* notification, gint timeout);
    /** 
     * Sets the category of this notification. This can be used by the notification server to filter or display the data in a certain way.
     * Params:
     *   notification = The notification.
     *   category = The category.
     */
    void notify_notification_set_category(NotifyNotification* notification, const char* category);
    /** 
     * Sets the urgency level of this notification.
     * Params:
     *   notification = The notification.
     *   urgency = The urgency level.
     */
    void notify_notification_set_urgency(NotifyNotification *notification, NotifyUrgency urgency);
    /** 
     * Sets a hint for key with value value . If value is NULL, a previously set hint for key is unset.
     *
     * If value is floating, it is consumed.
     * Params:
     *   notification = a NotifyNotification
     *   key = the hint key
     *   value = the hint value, or null to unset the hint. 
     */
    void notify_notification_set_hint(NotifyNotification* notification, const char* key, GVariant* value);

    /** 
     * Clears all hints from the notification.
     * Params:
     *   notification = The notification.
     */
    void notify_notification_clear_hints(NotifyNotification* notification);
    /** 
     * Clears all actions from the notification.
     * Params:
     *   notification = The notification.
     */
    void notify_notification_clear_actions(NotifyNotification* notification);

    /** 
     * Adds an action to a notification. When the action is invoked, the specified callback function will be called, along with the value passed to user_data.
     * Params:
     *   notification = The notification.
     *   action = The action ID.
     *   label = The human-readable action label.
     *   callback = The action's callback function.
     *   user_data = Optional custom data to pass to callback .
     *   free_func = An optional function to free user_data when the notification is destroyed. 
     */
    void notify_notification_add_action(NotifyNotification* notification, const char* action, const char* label,
                NotifyActionCallback callback, gpointer user_data, GFreeFunc free_func);

    /** 
     * Synchronously tells the notification server to hide the notification on the screen.
     * Params:
     *   notification = The notification.
     *   error = The returned error information.
     * Returns: true on success, or false on error with error filled in
     */
    gboolean notify_notification_close(NotifyNotification* notification, GError** error);

    /** 
     * Returns the closed reason code for the notification. This is valid only after the "closed" signal is emitted.
     * Params:
     *   notification = The notification.
     * Returns: The closed reason code.
     */
    gint notify_notification_get_closed_reason(const NotifyNotification* notification);
}

unittest
{
    auto n = notify_notification_new("Summary", "Body", null);
    assert(n != null);

    assert(notify_notification_update(n, "New Summary", "New Body", null) != false);

    import libnotify.notify;

    notify_init("application");
    assert(notify_notification_show(n, null) != false);
    notify_uninit();
}