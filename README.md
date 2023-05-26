# Choose-a-Door

Retrocoder Presents...

Where are we?<br>
...1993

A simple boolean game of chance for the web (HTML+' Fillable Forms/CGI/<b>Perl 4</b>)

## Live Demo

http://joz3d.net/cgi-bin/door.pl

For a true retro experience, <a href="https://oldweb.today/?browser=nm2-mac#http://joz3d.net/cgi-bin/door.pl">run it in Mosaic 2</a>.

## General Comments

What can I say about it... it's Perl 4, so all variables are global.  It tracks players' sesssions by IP, which is probably the best method one came up with in '93.

## Install
These are Apache-based instructions and will need to be adjusted respectively for other web servers.
1. Make sure you have CGI enabled (mod_cgid)
2. Disable web server caching of HTML and Perl scripts for this app.  One method would be creating the following `.htaccess` file in the same directory you put this app in:
```
<filesMatch "\.(html|pl)$">
  FileETag None
  <ifModule mod_headers.c>
     Header unset ETag
     Header set Cache-Control "max-age=0, no-cache, no-store, must-revalidate"
     Header set Pragma "no-cache"
     Header set Expires "Wed, 11 Jan 1984 05:00:00 GMT"
  </ifModule>
</filesMatch>
```
3. In `door.pl` set `$scriptloc`, `$assetloc`, and `$homepage` variables.  (`$scriptloc` and `$assetloc` can be the same location)
4. Optional, but you _might_ wanna put in a daily/weekly/monthly? cronjob to delete `temp-door-*` files that are older than an hour or so (even though they are literally 1 byte a pop) just for cleanup reasons.  The script tries to do its best job of cleaning up temp files, but can't really account for mid-game quit-outs.
