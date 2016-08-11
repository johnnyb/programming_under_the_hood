/* PURPOSE:  This program is meant to be an example
           of what GUI programs look like written
           with the GNOME libraries
 */ 

#include &lt;gnome.h&gt;

/* Program definitions */
#define MY_APP_TITLE "Gnome Example Program"
#define MY_APP_ID "gnome-example"
#define MY_APP_VERSION "1.000"
#define MY_BUTTON_TEXT "I Want to Quit the Example Program"
#define MY_QUIT_QUESTION "Are you sure you want to quit?"

/* Must declare functions before they are used */
int destroy_handler(gpointer window, 
		GdkEventAny *e, 
		gpointer data);
int delete_handler(gpointer window, 
		GdkEventAny *e, 
		gpointer data);
int click_handler(gpointer window, 
		GdkEventAny *e, 
		gpointer data);

int main(int argc, char **argv)
{
	gpointer appPtr;  /* application window */
	gpointer btnQuit; /* quit button */

	/* Initialize GNOME libraries */
	gnome_init(MY_APP_ID, MY_APP_VERSION, argc, argv);

	/* Create new application window */
	appPtr = gnome_app_new(MY_APP_ID, MY_APP_TITLE);

	/* Create new button */
	btnQuit = gtk_button_new_with_label(MY_BUTTON_TEXT);

	/* Make the button show up inside the application window */
	gnome_app_set_contents(appPtr, btnQuit);

	/* Makes the button show up */
	gtk_widget_show(btnQuit);

	/* Makes the application window show up */
	gtk_widget_show(appPtr);

	/* Connect the signal handlers */
	gtk_signal_connect(appPtr, "delete_event", 
			GTK_SIGNAL_FUNC(delete_handler), NULL);
	gtk_signal_connect(appPtr, "destroy", 
			GTK_SIGNAL_FUNC(destroy_handler), NULL);
	gtk_signal_connect(btnQuit, "clicked", 
			GTK_SIGNAL_FUNC(click_handler), NULL);

	/* Transfer control to GNOME */
	gtk_main();
	
	return 0;
}


/* Function to receive the "destroy" signal */
int destroy_handler(gpointer window, 
		GdkEventAny *e, 
		gpointer data)
{
	/* Leave GNOME event loop */
	gtk_main_quit();
	return 0;
}

/* Function to receive the "delete_event" signal */
int delete_handler(gpointer window, 
		GdkEventAny *e, 
		gpointer data)
{
	return 0;
}

/* Function to receive the "clicked" signal */
int click_handler(gpointer window, 
		GdkEventAny *e, 
		gpointer data)
{
	gpointer msgbox;
	int buttonClicked;

	/* Create the "Are you sure" dialog */
	msgbox = gnome_message_box_new(
		MY_QUIT_QUESTION, 
		GNOME_MESSAGE_BOX_QUESTION, 
		GNOME_STOCK_BUTTON_YES, 
		GNOME_STOCK_BUTTON_NO, 
		NULL);
	gtk_window_set_modal(msgbox, 1);
	gtk_widget_show(msgbox);

	/* Run dialog box */
	buttonClicked = gnome_dialog_run_and_close(msgbox);

	/* Button 0 is the Yes button.  If this is the
	button they clicked on, tell GNOME to quit
	it's event loop.  Otherwise, do nothing */
	if(buttonClicked == 0)
	{
		gtk_main_quit();
	}

	return 0;
}

