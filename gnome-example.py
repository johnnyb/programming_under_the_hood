#PURPOSE:  This program is meant to be an example
#          of what GUI programs look like written
#          with the GNOME libraries
#

#Import GNOME libraries
import gtk
import gnome.ui

####DEFINE CALLBACK FUNCTIONS FIRST####

#In Python, functions have to be defined before 
#they are used, so we have to define our callback 
#functions first.

def destroy_handler(event):
	gtk.mainquit()
	return 0

def delete_handler(window, event):
	return 0

def click_handler(event):
	#Create the "Are you sure" dialog
	msgbox = gnome.ui.GnomeMessageBox(
		"Are you sure you want to quit?", 
		gnome.ui.MESSAGE_BOX_QUESTION, 
		gnome.ui.STOCK_BUTTON_YES, 
		gnome.ui.STOCK_BUTTON_NO)
	msgbox.set_modal(1)
	msgbox.show()

	result = msgbox.run_and_close()

	#Button 0 is the Yes button.  If this is the
	#button they clicked on, tell GNOME to quit
	#it's event loop.  Otherwise, do nothing
	if (result == 0):
		gtk.mainquit()	

	return 0

####MAIN PROGRAM####

#Create new application window
myapp = gnome.ui.GnomeApp(
	"gnome-example", "Gnome Example Program")

#Create new button
mybutton = gtk.GtkButton(
	"I Want to Quit the GNOME Example program")
myapp.set_contents(mybutton)

#Makes the button show up 
mybutton.show()

#Makes the application window show up
myapp.show()

#Connect signal handlers
myapp.connect("delete_event", delete_handler)
myapp.connect("destroy", destroy_handler)
mybutton.connect("clicked", click_handler)

#Transfer control to GNOME
gtk.mainloop()

