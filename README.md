# pdf2cbz

Simple shell script to monitor a folder and all subfolders and convert all PDF files to CBZ archive.
Meant to be run at regular intervals, script will exit if no pdf files are found in the monitored folder or any of its subfolders.

Requirements:
- pdftocairo, zip and trash-cli (or just replace trash commands in script with rm if you prefer;)

Usage:
- Set a cron job to run it at regular intervals, daily, weekly...

