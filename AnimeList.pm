#### AnimeList ####
package AnimeList;

use strict;
use warnings;
use Switch;
use LWP::Simple;
use XML::Simple;
use Sub::Exporter -setup =>{ exports => [ qw(getWatching getCompleted getOnHold getPTW) ]};

my @Watching;
my @Completed;
my @OnHold;
my @PTW;

our $VERSION = '0.01';

sub setMyAnime {
	my $FILE = get("http://mal-api.com/animelist/cwarlord87?format=xml");

	my $xs1 = XML::Simple->new();
	my $doc = $xs1->XMLin($FILE);	
	
	foreach my $key (keys (%{$doc->{'anime'}}))
	{
		 my $ID = $key;
		 my $FILENAME = "AnimeListImages/" . $ID . ".jpg";
		 my $TITLE = $doc->{'anime'}->{$key}->{'title'};
		 my $EPISODES = $doc->{'anime'}->{$key}->{'episodes'};
		 my $STATUS = $doc->{'anime'}->{$key}->{'status'};
		 my $WATCHEDS = $doc->{'anime'}->{$key}->{'watched_status'};
		 my $SCORE = $doc->{'anime'}->{$key}->{'score'};
		 my $TYPE = $doc->{'anime'}->{$key}->{'type'};
		 my $IMAGE = $doc->{'anime'}->{$key}->{'image_url'};
		 dl_image($IMAGE,$FILENAME);		 
	 
			 switch($WATCHEDS) 
			 {
				 case 'completed' { push (@Completed, [$ID,$TITLE,$TYPE,$EPISODES,$SCORE]);	}
				 case 'plan to watch' {	push (@PTW, [$ID,$TITLE,$TYPE,$EPISODES]); }
				 case 'on-hold' { push (@OnHold, [$ID,$TITLE,$TYPE,$EPISODES]);	}
				 case 'watching' { push (@Watching, [$ID,$TITLE,$TYPE,$EPISODES]); }
			 }
	}  
}

# Sorted Watching 
sub getWatching { my $num = shift; return (sort { $a->[$num] cmp $b->[$num] } @Watching); }
# Sorted Completed
sub getCompleted { my $num = shift; return (sort { $a->[$num] cmp $b->[$num] } @Completed); }
# Sorted OnHold
sub getOnHold { my $num = shift; return (sort { $a->[$num] cmp $b->[$num] } @OnHold); }
#Sorted PTW
sub getPTW { my $num = shift; return (sort { $a->[$num] cmp $b->[$num] } @PTW); }



sub dl_image {
	my $IMAGE = shift;
	my $FILENAME = shift;
	 unless (-e $FILENAME){
		my $IMG = get($IMAGE);	
			open (FH, ">$FILENAME");
			binmode (FH);
			print FH $IMG;
			close (FH);
	 }
}


#####################
# Package: Anime
# Function: getAnime
#####################

package Anime;
use strict;
use warnings;
use Switch;
use LWP::Simple;
use XML::LibXML;

sub getAnime {
	my $KEY = shift;
	my $xsl = XML::LibXML->new();
	my $FILE = get("http://mal-api.com/anime/" . $KEY . "?format=xml");
	my $doc2 = $xsl->load_xml(string => $FILE);	
	my $GENRE = "";
		foreach my $gne ($doc2->findnodes('/anime/genre')) {
		    if($GENRE eq "")
		    {
				$GENRE = $gne->to_literal;
			}
			else
			{    
				$GENRE = $GENRE .", " . $gne->to_literal;
			}
		}
	my $TITLE = $doc2->findnodes('/anime/title')->to_literal;
	my $RANK = $doc2->findnodes('/anime/rank')->to_literal;
	my $STATUS = $doc2->findnodes('/anime/status')->to_literal;
	my $RATING = $doc2->findnodes('/anime/classification')->to_literal;
	my $MSCORE = $doc2->findnodes('/anime/members_score')->to_literal;
	my $SYNOPSIS = $doc2->findnodes('/anime/synopsis')->to_literal;
		$SYNOPSIS =~ s/<br>/\\n/g;

  return ($TITLE,$RANK,$MSCORE,$STATUS,$RATING,$GENRE,$SYNOPSIS);
   
}

#####################
# Package: UserStats
# Function: UserStatus
#####################

package UserStats;
use strict;
use warnings;
use XML::LibXML;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use base 'Gtk2::Statusbar';

sub UserStatus {
	my($class) = shift;
	
	my $self = bless Gtk2::Statusbar->new,$class;
	my $context_id = $self->get_context_id( "UserStats" );
	
	my $xsl = XML::LibXML->new();
	my $doc = $xsl->load_xml(location => "http://myanimelist.net/malappinfo.php?status=all&u=cwarlord87");
		$self->{ID} = $doc->findnodes('myanimelist/myinfo/user_id')->to_literal;
		$self->{NAME} = $doc->findnodes('myanimelist/myinfo/user_name')->to_literal;
		$self->{WATCHING} = $doc->findnodes('myanimelist/myinfo/user_watching')->to_literal;
		$self->{COMPLETED} = $doc->findnodes('myanimelist/myinfo/user_completed')->to_literal;
		$self->{ONHOLD} = $doc->findnodes('myanimelist/myinfo/user_onhold')->to_literal;
		$self->{PTW} = $doc->findnodes('myanimelist/myinfo/user_plantowatch')->to_literal;
		$self->{DSW} = $doc->findnodes('myanimelist/myinfo/user_days_spent_watching')->to_literal;
	my $buff = "Watching: " . $self->{WATCHING} . "\t\tCompleted: " . $self->{COMPLETED} . "\t\tOn Hold: " . $self->{ONHOLD} . "\t\tPlan To Watch: " . $self->{PTW} . "\t\tDays Watching Anime: " . $self->{DSW};
		$self->push($context_id,$buff);

	return $self;
}

#####################
# Package: InfoWindow
# Function: new
# Function: set_Window
#####################

package InfoWindow;

use strict;
use warnings;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/;
use base 'Gtk2::Window';

sub new {
	my $class = shift;
	my $false = 0;
	my $true = 1;
	my $self = bless Gtk2::Window->new()->set_position_('center-always'),$class;
	my $imgPic = Gtk2::Image->new;
	my $lblRank = Gtk2::Label->new()->set_line_wrap_( $true);	
	my $lblMScore = Gtk2::Label->new()->set_line_wrap_( $true);
	my $lblRating = Gtk2::Label->new()->set_line_wrap_( $true);
	my $lblGenres = Gtk2::Label->new()->set_line_wrap_( $true);
	my $lblStatus = Gtk2::Label->new()->set_line_wrap_( $true);
	my $vbox_info = Gtk2::VBox->new($false,5);
		

		$imgPic->set_pixel_size(500);
		# Set labels
		$lblRank->set_alignment(0,1);
		$lblMScore->set_alignment(0,1);	
		$lblRating->set_alignment(0,1);
		$lblGenres->set_alignment(0,1);
		$lblStatus->set_alignment(0,1);	
		$vbox_info->set_size_request (500, 500);
	
		#Attach defaults to table;
	my $table = Gtk2::Table->new(3,5,$false)->attach_defaults_($lblRank,0,3,0,1)->attach_defaults_($lblMScore,0,3,1,2)->attach_defaults_($lblStatus,0,3,2,3)->attach_defaults_($lblRating,0,3,3,4)->attach_defaults_($lblGenres,0,3,4,5);
		
		$vbox_info->pack_start($imgPic,$false,$false,0);
		$vbox_info->pack_start(Gtk2::HSeparator->new(),FALSE,FALSE,5);
		$vbox_info->pack_start($table,$false,$false,0);		
		$vbox_info->show_all;
		
		$self->add($vbox_info);
		$self->{pic} = $imgPic;
		$self->{rank} = $lblRank;
		$self->{score} = $lblMScore;
		$self->{rating} = $lblRating;
		$self->{genre} = $lblGenres;
		$self->{status} = $lblStatus;
		$self->signal_connect('delete_event'=>\&Gtk2::Widget::hide_on_delete);

		return $self;
}

sub set_Window
{
	my ($self,$title,$rank,$score,$status,$rating,$genre,$synopsis,$pic) = @_;
		$self->set_title($title);
		$self->{pic}->set_from_file($pic);
		$self->{rank}->set_text("Rank: " . $rank);	
		$self->{score}->set_text("Members Score: " . $score);
		$self->{rating}->set_text("Rating: " . $rating);
		$self->{genre}->set_text("Genres: " . $genre);
		$self->{status}->set_text("Status: " . $status);
	return $self;
}
