module libnotify.notify;

import glib;

extern(C)
{
    /** 
     * Initialized libnotify. This must be called before any other functions.
     * Params:
     *   app_name = The name of the application initializing libnotify.
     * Returns: true if successful, or false on error.
     */
    gboolean notify_init(const char* app_name);

    /** 
     * Uninitializes libnotify.
     *
     * This should be called when the program no longer needs libnotify for the rest of its lifecycle, typically just before exitting.
     */
    void notify_uninit();
    /** 
     * Gets whether or not libnotify is initialized.
     * Returns: true if libnotify is initialized, or false otherwise.
     */
    gboolean notify_is_initted();

    /** 
     * Gets the application name registered.
     * Returns: The registered application name, passed to notify_init().
     */
    const(char)* notify_get_app_name();
    /** 
     * Sets the application name.
     * Params:
     *   app_name = The name of the application
     */
    void notify_set_app_name(const char* app_name);

    /** 
     * Synchronously queries the server for its capabilities and returns them in a GList.
     * Returns: a GList of server capability strings. Free the list elements with g_free() and the list itself with g_list_free(). 
     */
    GList* notify_get_server_caps();

    /** 
     * Synchronously queries the server for its information, specifically, the name, vendor, server version, and the version of the notifications specification that it is compliant with.
     * Params:
     *   ret_name = a location to store the server name, or null. 
     *   ret_vendor = a location to store the server vendor, or null. 
     *   ret_version = a location to store the server version, or null. 
     *   ret_spec_version = a location to store the version the service is compliant with, or null. 
     * Returns: true if successful, and the variables passed will be set, false on error. The returned strings must be freed with g_free
     */
    int notify_get_server_info(char** ret_name, char** ret_vendor, char** ret_version, char** ret_spec_version);
}

unittest
{
    assert(notify_init("application") != false);

    import std.stdio, std.string, std.conv;
    assert(to!string(notify_get_app_name()) == "application");

    notify_set_app_name("application!");
    assert(to!string(notify_get_app_name()) == "application!");

    assert(notify_is_initted() == true);
    notify_uninit();
    assert(notify_is_initted() == false);
}