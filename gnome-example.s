#PURPOSE:  This program is meant to be an example
#          of what GUI programs look like written
#          with the GNOME libraries
#
#INPUT:    The user can only click on the "Quit"
#          button or close the window
#
#OUTPUT:   The application will close
#
#PROCESS:  If the user clicks on the "Quit" button,
#          the program will display a dialog asking
#          if they are sure.  If they click Yes, it
#          will close the application.  Otherwise
#          it will continue running
#          

.section .data

###GNOME definitions - These were found in the GNOME
#                      header files for the C language
#                      and converted into their assembly
#                      equivalents

#GNOME Button Names
GNOME_STOCK_BUTTON_YES:
.ascii "Button_Yes\0"
GNOME_STOCK_BUTTON_NO:
.ascii "Button_No\0"

#Gnome MessageBox Types
GNOME_MESSAGE_BOX_QUESTION:
.ascii "question\0"

#Standard definition of NULL
.equ NULL, 0

#GNOME signal definitions
signal_destroy:
.ascii "destroy\0"
signal_delete_event:
.ascii "delete_event\0"
signal_clicked:
.ascii "clicked\0"

###Application-specific definitions

#Application information
app_id:
.ascii "gnome-example\0"
app_version:
.ascii "1.000\0"
app_title:
.ascii "Gnome Example Program\0"

#Text for Buttons and windows
button_quit_text:
.ascii "I Want to Quit the GNOME Example Program\0"
quit_question:
.ascii "Are you sure you want to quit?\0"


.section .bss

#Variables to save the created widgets in
.equ WORD_SIZE, 4
.lcomm appPtr, WORD_SIZE
.lcomm btnQuit, WORD_SIZE

.section .text

.globl main
.type main,@function
main:
	pushl %ebp
	movl  %esp, %ebp

	#Initialize GNOME libraries
	pushl 12(%ebp)     #argv
	pushl 8(%ebp)      #argc
	pushl $app_version 
	pushl $app_id      
	call  gnome_init
	addl  $16, %esp    #recover the stack

	#Create new application window
	pushl $app_title    #Window title
	pushl $app_id       #Application ID
	call  gnome_app_new
	addl  $8, %esp      #recover the stack
	movl  %eax, appPtr  #save the window pointer

	#Create new button
	pushl $button_quit_text #button text
	call  gtk_button_new_with_label
	addl  $4, %esp          #recover the stack
	movl  %eax, btnQuit     #save the button pointer

	#Make the button show up inside the application window
	pushl btnQuit
	pushl appPtr
	call  gnome_app_set_contents
	addl  $8, %esp

	#Makes the button show up (only after it's window
	#shows up, though)
	pushl btnQuit
	call  gtk_widget_show
	addl  $4, %esp

	#Makes the application window show up
	pushl appPtr
	call  gtk_widget_show
	addl  $4, %esp

	#Have GNOME call our delete_handler function
	#whenever a "delete" event occurs
	pushl $NULL            #extra data to pass to our
	                       #function (we don't use any)
	pushl $delete_handler  #function address to call
	pushl $signal_delete_event #name of the signal
	pushl appPtr           #widget to listen for events on
	call  gtk_signal_connect
	addl  $16, %esp        #recover stack

	#Have GNOME call our destroy_handler function
	#whenever a "destroy" event occurs
	pushl $NULL            #extra data to pass to our
	                       #function (we don't use any)
	pushl $destroy_handler #function address to call
	pushl $signal_destroy  #name of the signal
	pushl appPtr           #widget to listen for events on
	call  gtk_signal_connect
	addl  $16, %esp        #recover stack

	#Have GNOME call our click_handler function
	#whenever a "click" event occurs.  Note that
	#the previous signals were listening on the
	#application window, while this one is only
	#listening on the button
	pushl $NULL
	pushl $click_handler
	pushl $signal_clicked
	pushl btnQuit
	call  gtk_signal_connect
	addl  $16, %esp

	#Transfer control to GNOME.  Everything that
	#happens from here out is in reaction to user
	#events, which call signal handlers.  This main
	#function just sets up the main window and connects
	#signal handlers, and the signal handlers take 
	#care of the rest
	call  gtk_main

	#After the program is finished, leave
	movl  $0, %eax
	leave
	ret

#A "destroy" event happens when the widget is being
#removed.  In this case, when the application window
#is being removed, we simply want the event loop to
#quit
destroy_handler:
	pushl %ebp
	movl  %esp, %ebp

	#This causes gtk to exit it's event loop
	#as soon as it can.
	call  gtk_main_quit

	movl  $0, %eax
	leave
	ret

#A "delete" event happens when the application window 
#gets clicked in the "x" that you normally use to 
#close a window
delete_handler:
	movl  $1, %eax
	ret

#A "click" event happens when the widget gets clicked
click_handler:
	pushl %ebp
	movl  %esp, %ebp

	#Create the "Are you sure" dialog
	pushl $NULL                       #End of buttons
	pushl $GNOME_STOCK_BUTTON_NO      #Button 1
	pushl $GNOME_STOCK_BUTTON_YES     #Button 0
	pushl $GNOME_MESSAGE_BOX_QUESTION #Dialog type
	pushl $quit_question              #Dialog mesasge
	call  gnome_message_box_new
	addl  $16, %esp                   #recover stack

	#%eax now holds the pointer to the dialog window

	#Setting Modal to 1 prevents any other user
	#interaction while the dialog is being shown
	pushl $1
	pushl %eax
	call  gtk_window_set_modal
	popl  %eax
	addl  $4, %esp

	#Now we show the dialog	
	pushl %eax
	call  gtk_widget_show
	popl  %eax

	#This sets up all the necessary signal handlers
	#in order to just show the dialog, close it when
	#one of the buttons is clicked, and return the
	#number of the button that the user clicked on.
	#The button number is based on the order the buttons
	#were pushed on in the gnome_message_box_new function
	pushl %eax	
	call  gnome_dialog_run_and_close
	addl  $4, %esp

	#Button 0 is the Yes button.  If this is the
	#button they clicked on, tell GNOME to quit
	#it's event loop.  Otherwise, do nothing
	cmpl  $0, %eax
	jne   click_handler_end

	call  gtk_main_quit

click_handler_end:
	leave
	ret
