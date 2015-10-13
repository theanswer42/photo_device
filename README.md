# photo_device
Objectives
==========
 - Raspberry pi automatically copies things from flash card(s) on to attached
   usb external storage. Flash drives connected via usb card reader.
 - Status indicated with two status LED's driven by GPIO
 - Only copy new files

For v1
======
 - No file structure when copying. All files copied into one directory.
 - duplicates copied with _n suffix
 - sha256 checksums used for duplicate check
 - checksums verified on target device before we're done.
 - indicate "ready", "copying" and "error" states

System inputs, outputs
======================
Inputs
 - Identify that disk is attached
 - Identify that cards are attached

Outputs
 - ready
 - copying
 - error

Required components
===================
 - New runlevel (systemd components)
 - task to scan for devices and figure out what we have
 - USB hotplug scripts for:
   - disk
   - cards
 - copy script
 - On error, make sure stuff gets saved first.

Installed files
===============
 - systemd (TBD)
 - usb (TBD)
 - gpio control (TBD)
 - status
   <prefix>/run
       /disk -> path to target drive
       /cards -> each line is path to source device
       /working -> exists if we're working. Line contains card device being
       		   copied
       /error -> exists if error. This should be moved somewhere on shutdown
       /ready -> exists if everything is ready to go (also indicates that an
                 operation is done)
 - <prefix>/bin
       /copy_photos.rb -> Copy stuff!

