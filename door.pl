#!/usr/bin/perl

# "Choose a Door"
# by Joz
#
# A simple boolean game of chance for the web (CGI/Perl 4).

print "Content-type: text/html\n\n";

$debug = 0;
$scriptloc = "http://localhost/cgi-bin";		# Where door.pl is located
$assetloc = "http://localhost/cgi";				# Where door graphics are
												# 	(no trailing slashes)
$homepage = "../index.html";					# Homepage location
$homepage_name = "Joz's Homepage";

$scorefile = "temp-door-score-".$ENV {REMOTE_ADDR};
$nrfile = "temp-door-record-".$ENV {REMOTE_ADDR};
$hiscorefile = "door-hiscore";
$playcountfile = "door-playcount";

$hiscore = &open_scorefile ("r", $hiscorefile, 0);		# Load high score
$playcount = &open_scorefile ("r", $playcountfile, 0);	# Load play count
$score = 0;

($input) = $ENV{'QUERY_STRING'} =~ m/=(\w+)/;	# Determine input parameter

# Load scores (create files) only if we are currently in a game
if (($input eq "Left") || ($input eq "Right") || ($input eq "Continue"))
{
	$score = &open_scorefile ("r", $scorefile, 0);	# Open session score file
	$newhigh = &open_scorefile ("r", $nrfile, 0);	# Load new record status
}

# If user did not make a selection; draw game page and exit
unless (($input eq "Left") || ($input eq "Right"))
{
	&draw_page ("game");
	exit 1;
}

$choice = 0;
if ($input eq "Right")						# Convert user selection to binary
{
	$choice = 1;
}

$result = int (rand (2));					# See what we roll

if ($debug == 1)
{
	print "
	Query String: $ENV{'QUERY_STRING'}
	<p>
	User chose: $choice ($input)
	<p>
	Actual result: $result
	";
}

if ($choice == $result)			# If they guessed right
{
	$score++;
	&open_scorefile ("w", $scorefile, $score);	# Update the score in the file

	if ($score > $hiscore)				# If we broke the high score, record it!
	{
		$hiscore = $score;
		$newhigh = 1;
		&open_scorefile ("w", $hiscorefile, $hiscore);	# Update high score file
		&open_scorefile ("w", $nrfile, 1);	# Flag file tracking this New Record run
	}

	&draw_page ("win");
}
else							# If they guessed wrong
{
	&draw_page ("lose");
	unlink $scorefile, $nrfile or die "Unable to delete temp files";
	$playcount++;
	&open_scorefile ("w", $playcountfile, $playcount);
}


# Opens specified file in specified mode (read or write) and reads or writes the 
# specified data to/from it
sub open_scorefile
{
	local ($action, $scorefile, $score) = @_;

	# Load data from file if it exists.  Create it if it does not exist.
	if ($action eq "r")
	{
		if (-e $scorefile)
		{
			open SCOREFILE, "$scorefile" or die "Can't open $scorefile for reading: $!";
			$score = <SCOREFILE>;
		}
		else
		{
			open SCOREFILE, ">$scorefile" or die "Can't open $scorefile for writing: $!";
			print SCOREFILE $score;
		}
	}
	if ($action eq "w")		# Write data to file
	{
		open SCOREFILE, ">$scorefile" or die "Can't open $scorefile for writing: $!";
		print SCOREFILE $score;
	}

	chmod 0664, $scorefile;	# Had issues with user ownership changing over time, so make
	close SCOREFILE;		# files group writable as well.
	return ($score);
}


# Creates various versions (as specified) of the HTML page
sub draw_page
{
	$pagetype = pop (@_);
	if ($pagetype eq "game")				# Main/Game Page
	{
		&page_header ("Choose a Door");

		# Draw doors & buttons
		print "
			<img src=\"$assetloc/door.gif\">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp<img src=\"$assetloc/door.gif\">
		</p>

		<form method=\"get\" action=\"$scriptloc/door.pl\">
			<p align=\"center\">
				<input type=\"submit\" name=\"Choice\" value=\"Left\" action=\"send\"> 
				<input type=\"submit\" name=\"Choice\" value=\"Right\" action=\"send\">
			</p>
		</form>
		";
	}
	elsif ($pagetype eq "win")				# Win Page
	{
		&page_header ("Good Choice!");
		
		# Draw doors & buttons
		if ($choice == 0)
		{
			print "
			<img src=\"$assetloc/door-open.gif\">
			&nbsp;&nbsp;&nbsp;
			<img src=\"$assetloc/door.gif\">
			";
		}
		else
		{
			print "
			<img src=\"$assetloc/door.gif\">
			&nbsp;&nbsp;&nbsp;
			<img src=\"$assetloc/door-open.gif\">
			";
		}
		print "
		</p>

		<form method=\"get\" action=\"$scriptloc/door.pl\">
			<p align=\"center\">
				<input type=\"submit\" name=\"Choice\" value=\"Continue\" action=\"send\">
			</p>
		</form>
		";
	}
	elsif ($pagetype eq "lose")				# Lose Page
	{
		&page_header ("Game Over");
		
		# Draw doors & buttons
		if ($choice == 1)
		{
			print "
			<img src=\"$assetloc/door.gif\">
			&nbsp;&nbsp;&nbsp;
			<img src=\"$assetloc/door-bricks.gif\">
			";
		}
		else
		{
			print "
			<img src=\"$assetloc/door-bricks.gif\">
			&nbsp;&nbsp;&nbsp;
			<img src=\"$assetloc/door.gif\">
			";
		}

		print "
		</p>
		<form method=\"get\" action=\"$scriptloc/door.pl\">
			<p align=\"center\">
				<input type=\"submit\" name=\"Choice\" value=\"Try Again!\" action=\"send\"> 
			</p>
		</form>
		";
	}

	&page_footer;
}


# Create page header (including status message, high & current scores)
sub page_header
{
	$message = pop (@_);

	print "
	<html>
	<head>
		<title>Door Game</title>
	</head>

	<body>
	<h1>$message</h1>
	<hr>

	<p align=\"right\">
		High Score: $hiscore
	</p>

	<p align=\"center\">
	";
	if ($pagetype eq "lose")
	{
		print "Final ";
	}
	print "
	Score: <b>$score</b>
	";
	if ($newhigh == 1)
	{
		print " (New Record!)";
	}
	print "
	</p>

	<p align=\"center\">
	";
}


# Create page footer
sub page_footer
{
	print "
	<hr>
	<p align=\"center\">
		This game has been played $playcount times.
	</p>
	<br>
	<p align=\"center\">
		<a href=\"$homepage\"><img src=\"$assetloc/back.gif\"></a>
	</p>
	<p align=\"center\">
		Back to <a href=\"$homepage\">$homepage_name</a>
	</p>
	</body>
	</html>
	";
}
