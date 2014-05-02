#!/usr/local/bin/perl -w

#id
#title
#synopsis
#type
#rank
#popularity_rank
#image_url
#episodes
#status
#classification
#members_score
#members_count
#favorited_count
#listed_anime_id
#watched_episodes
#score
#watched_status			completed, plan to watch


use LWP::Simple;
use XML::Simple;
use strict;
use File::Slurp qw(slurp);
use File::Slurp;
use Switch;
use HTML::Table;
use XML::LibXML;
my $URL = "http://myanimelist.net/malappinfo.php?status=anime&u=cwarlord87";
my $FILE = get($URL);
print $FILE;
my $tblWatching = new HTML::Table(-border=>2, -spacing=>1, -padding=>1,  -head=> ['Title','Rank','MScore', 'Episodes','Score','Genre','Rating']);
my $tblWatched = new HTML::Table(-border=>2, -spacing=>1, -padding=>1, -head=> ['Title', 'Rank','MScore', 'Episodes','Score','Genre','Rating']);
my $tblOnHold = new HTML::Table(-border=>2, -spacing=>1, -padding=>1, -head=> ['Title', 'Rank', 'MScore','Episodes','Genre','Rating']);
my $tblPTW = new HTML::Table(-border=>2, -spacing=>1, -padding=>1, -head=> ['Title', 'Rank', 'MScore','Episodes','Genre','Rating']);


open FH, ">>Anime.html" or die "can't open 'Anime.html': $!"; # <<<< outside the loop
my $xs1 = XML::Simple->new();

my $doc = $xs1->XMLin($FILE);

foreach my $key (keys (%{$doc->{'anime'}})){

#my $xsl2 = XML::LibXML->new();
 #my $GENRE = "";
 #my $URL2 = "http://mal-api.com/anime/" . $key . "?format=xml";
 #my $FILE2 = get($URL2);
 #my $doc2 = $xsl2->load_xml(string => $FILE2);
 #foreach my $gne ($doc2->findnodes('/anime/genre')) {
    #if($GENRE eq "")
    #{
		#$GENRE = $gne->to_literal;
	#}
	#else
	#{    
		#$GENRE = $GENRE ."," . $gne->to_literal;
	#}
  #}

 my $TITLE = $doc->{'anime'}->{$key}->{'title'};
 my $EPISODES = $doc->{'anime'}->{$key}->{'episodes'};
 my $STATUS = $doc->{'anime'}->{$key}->{'status'};
 my $WATCHEDS = $doc->{'anime'}->{$key}->{'watched_status'};
 my $RANK = $doc2->findnodes('/anime/rank');
 my $SCORE = $doc->{'anime'}->{$key}->{'score'};
 my $RATING = $doc2->findnodes('/anime/classification');
 my $MSCORE = $doc2->findnodes('/anime/members_score');
 switch($WATCHEDS) {
	 case 'completed' { 
		$tblWatched->addRow($TITLE,$RANK->to_literal,$MSCORE->to_literal,$EPISODES,$SCORE,$GENRE,$RATING->to_literal);}
	 case 'plan to watch' {
		$tblPTW->addRow($TITLE,$RANK->to_literal,$MSCORE->to_literal,$EPISODES,$GENRE,$RATING->to_literal);}
	 case 'on-hold' {
		$tblOnHold->addRow($TITLE,$RANK->to_literal,$MSCORE->to_literal,$EPISODES,$GENRE,$RATING->to_literal);}
	 case 'watching' {
		$tblWatching->addRow($TITLE,$RANK->to_literal,$MSCORE->to_literal,$EPISODES,$SCORE,$GENRE,$RATING->to_literal);}
	 }
}
$tblWatched->sort(-sort_col=>1,-sort_type=>'ALPHA',-sort_order=>'ASC',-skip_rows =>1);
$tblPTW->sort(-sort_col=>1,-sort_type=>'ALPHA',-sort_order=>'ASC',-skip_rows =>1);
$tblWatching->sort(-sort_col=>1,-sort_type=>'ALPHA',-sort_order=>'ASC',-skip_rows =>1);
$tblOnHold->sort(-sort_col=>1,-sort_type=>'ALPHA',-sort_order=>'ASC',-skip_rows =>1);

print FH "<HTML>\n<BODY>\n";
print FH "<h2>Currently Watching</h2>" . $tblWatching->getTable;
print FH "<br><br><h2>Completed</h2>" . $tblWatched->getTable;
print FH "<br><br><h2>On-Hold</h2>". $tblOnHold->getTable;
print FH "<br><br><h2>Plan To Watch</h2>" .$tblPTW->getTable;
print FH "</BODY></HTML>";

close FH;
