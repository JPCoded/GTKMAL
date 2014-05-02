#! /usr/bin/perl -w

use strict;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/; 
use Gtk2::Ex::Simple::List;
use Switch;
use LWP::Simple;
use XML::LibXML;
my $xsl = XML::LibXML->new();
my $doc = $xsl->load_xml(location => "http://myanimelist.net/malappinfo.php?status=all&u=cwarlord87");
my @type = (' ','TV','OVA','Movie','Special');
#create a treeview with the model.
my $tvCompleted = Gtk2::Ex::Simple::List->new ('Title' => 'text', 'Type' => 'text', 'Episodes' => 'text', 'Score' => 'text', 'Genre' => 'text');
my $tvWatching = Gtk2::Ex::Simple::List->new ('Title' => 'text', 'Type' => 'text', 'Episodes' => 'text', 'Genre' => 'text');
my $tvOnHold = Gtk2::Ex::Simple::List->new ('Title' => 'text', 'Type' => 'text', 'Episodes' => 'text', 'Genre' => 'text');
my $tvPTW = Gtk2::Ex::Simple::List->new ('Title' => 'text', 'Type' => 'text', 'Episodes' => 'text', 'Genre' => 'text');
 

           
foreach my $key ($doc->findnodes('myanimelist/anime')){
 my $TITLE = $key->findnodes('series_title')->to_literal;
 my $TYPE = $type[$key->findnodes('series_type')->to_literal];
 my $EPISODES = $key->findnodes('series_episodes')->to_literal;
 my $STATUS = $key->findnodes('series_status')->to_literal;
 my $WATCHEDS = $key->findnodes('my_status')->to_literal;
 my $GENRE = $key->findnodes('my_tags')->to_literal;
 my $SCORE = $key->findnodes('my_score')->to_literal;
	if($WATCHEDS eq '2') { push @{$tvCompleted->{data}}, [$TITLE,$TYPE,$EPISODES,$SCORE,$GENRE];}
	if($WATCHEDS eq '6') { push @{$tvPTW->{data}}, [$TITLE,$TYPE, $EPISODES,$GENRE];}
	if($WATCHEDS eq '3') { push @{$tvOnHold->{data}}, [$TITLE,$TYPE,$EPISODES,$GENRE];}
	if($WATCHEDS eq '1') { push @{$tvWatching->{data}}, [$TITLE,$TYPE,$EPISODES,$GENRE];}	 
}
my $scrlWatching = Gtk2::ScrolledWindow->new;
my $scrlCompleted = Gtk2::ScrolledWindow->new;
my $scrlOnHold = Gtk2::ScrolledWindow->new;
my $scrlPTW = Gtk2::ScrolledWindow->new;
#standard window creation, placement, and signal connecting
my $window = Gtk2::Window->new('toplevel');
$window->signal_connect('delete_event' => sub { Gtk2->main_quit; });
$window->set_border_width(5);
$window->set_position('center_always');

#add and show the vbox
$window->add(&ret_vbox);
$window->show();

#our main event-loop
Gtk2->main();



sub ret_vbox {

my $vbox = Gtk2::VBox->new(FALSE,5);

	#create a instance of the Gtk2::Expander class
	my $expander = Gtk2::Expander->new_with_mnemonic('Expand Me');
	
	#create the child that we want to add to it.
	#----------------------------------------------
	#NOTE: If we want to resize
	#the widget containing the Gtk2::Expander Widget 
	#to the size that it was BEFORE the expansion
	#we have to "add / remove" the child on each "expanded / closed" cycle
	#If we just add it, it will be shown and hidden, but we will not be able
	#to shrink the parent containing the Gtk2::Expander instance when hidden
	#-------------------------------------------------
	my $nb = &ret_notebook;
	$nb->show_all;
	
	$expander->signal_connect_after('activate' => sub {
			
		if($expander->get_expanded){
			$expander->set_label('Close Me');
			$expander->add($nb);
				
		}else{ 
			$expander->set_label('Expand Me');
			$expander->remove($nb);
			$window->resize(4,4);	
		}
		return FALSE;
	}); 
	
	
$vbox->pack_start($expander,FALSE,FALSE,0);	

$vbox->show_all();
return $vbox;
}

sub ret_notebook {

my $vbox_nb = Gtk2::VBox->new(FALSE,5);
$vbox_nb->set_size_request (1500, 750);

	my $nb = Gtk2::Notebook->new;

	$nb->set_scrollable (TRUE); 
	$nb->popup_enable;
	$scrlWatching->add($tvWatching);
	$scrlCompleted->add($tvCompleted);
	$scrlOnHold->add($tvOnHold);
	$scrlPTW->add($tvPTW);
	my $child;
	my @LIST = ('Watching','Completed','On-Hold','Plan To Watch');
		for (0..3) { 
		switch($_){
			case 0 { $child = $scrlWatching;}
			case 1 { $child = $scrlCompleted;}
			case 2 { $child = $scrlOnHold;}
			case 3 { $child = $scrlPTW;}
		}
	
		#The tab's label can be a widget, and does not
		#need to be a label, here we create a hbox containing
		#a label and close button
		my $hbox = Gtk2::HBox->new(FALSE,0);
		$hbox->pack_start(Gtk2::Label->new("$LIST[$_]"),FALSE,FALSE,0);
		$hbox->show_all;
		$nb->append_page ($child,$hbox);  

		} 
	
$vbox_nb->pack_start($nb,TRUE,TRUE,0);
$vbox_nb->pack_start(Gtk2::HSeparator->new(),FALSE,FALSE,5);
		
#$vbox_nb->pack_end(&nb_controls($nb),FALSE,FALSE,0);	
	
	return $vbox_nb;
}


sub nb_controls {

	my ($nb) = @_;
	
	my $table = Gtk2::Table->new(3,2,TRUE);
	
	$table->attach_defaults(Gtk2::Label->new('Tab position:'),0,1,0,1);
	
		my $cb_position = Gtk2::ComboBox->new_text;
		
		foreach my $val (qw/left right top bottom/){
		
			$cb_position->append_text($val);
		}
		
		$cb_position->signal_connect("changed" => sub {
		
			$nb->set_tab_pos($cb_position->get_active_text);
		
		});
		
		$cb_position->set_active(2);

	$table->attach_defaults($cb_position,1,2,0,1);
	
		my $show_tabs = Gtk2::CheckButton->new("Show Tabs");
		$show_tabs->set_active(TRUE);
		$show_tabs->signal_connect('toggled' =>sub {
		
			$nb->set_show_tabs($show_tabs->get_active);
		
		});
	$table->attach_defaults($show_tabs,0,1,1,2);
	
		my $scrollable = Gtk2::CheckButton->new("Scrollable");
		$scrollable->set_active(TRUE);
		$scrollable->signal_connect('toggled' =>sub {
		
			$nb->set_scrollable($scrollable->get_active);
		
		});
	$table->attach_defaults($scrollable,1,2,1,2);
	
		my $popup = Gtk2::CheckButton->new("Popup Menu (right click on tab)");
		$popup->set_active(TRUE);
		$popup->signal_connect('toggled' =>sub {
		
			($popup->get_active)&&($nb->popup_enable);
			($popup->get_active)||($nb->popup_disable);
		});
	$table->attach_defaults($popup,0,1,2,3);
	
	return $table;

}
