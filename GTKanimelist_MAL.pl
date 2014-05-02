#! /usr/bin/perl -w

use strict;
use warnings;
use Gtk2 '-init';
use Gtk2Fu qw(:all);
use Glib qw/TRUE FALSE/;
use Gtk2::Ex::Simple::List;
use Gtk2::Ex::Simple::Menu;
use Switch;
require 'AnimeList.pm';



use constant {
	FAL => 0,
	TRU => 1
};		
	
	my $pixbuf = Gtk2::Gdk::Pixbuf->new_from_file ("MAL.ico");
	#Ex::Simple::List
	my $slCompleted = Gtk2::Ex::Simple::List->new('ID'=>'text', 'Title' => 'text', 'Type' => 'text', 'Episodes' => 'text', 'My Score' => 'text');
		$slCompleted->signal_connect (row_activated => sub { my ($treeview, $path, $column) = @_; info_box($slCompleted->{data}[$_[1]->to_string][0]); });
	my $slWatching = Gtk2::Ex::Simple::List->new('ID'=>'text', 'Title' => 'text', 'Type' => 'text', 'Episodes' => 'text');
		$slWatching->signal_connect (row_activated => sub { my ($treeview, $path, $column) = @_; info_box($slWatching->{data}[$_[1]->to_string][0]); });
	my $slOnHold = Gtk2::Ex::Simple::List->new('ID'=>'text', 'Title' => 'text', 'Type' => 'text','Episodes' => 'text');
		$slOnHold->signal_connect (row_activated => sub { my ($treeview, $path, $column) = @_; info_box($slOnHold->{data}[$_[1]->to_string][0]); });
	my $slPTW = Gtk2::Ex::Simple::List->new ('ID'=>'text', 'Title' => 'text', 'Type' => 'text','Episodes' => 'text');
		$slPTW->signal_connect (row_activated => sub { my ($treeview, $path, $column) = @_; info_box($slPTW->{data}[$_[1]->to_string][0]); });
	
	AnimeList::setMyAnime();
	loadAnime(1);
	
	#ScrolledWindows
	my $scrlWatching = Gtk2::ScrolledWindow->new;
	my $scrlCompleted = Gtk2::ScrolledWindow->new;
	my $scrlOnHold = Gtk2::ScrolledWindow->new;
	my $scrlPTW = Gtk2::ScrolledWindow->new;
	
	
	my @lblInfo = ('Rank: ', 'Members Score: ', 'Raiting: ', 'Genres: ');
	
	
	my $window = create_window('cwarlord87 Anime List','toplevel', 0, 0, 5, sub { Gtk2->main_quit; })->set_position_('center_always')->set_icon_($pixbuf);

	
	#information Window
	my $infoWindow = InfoWindow->new();
	
		#add and show the vbox
		$window->add(&ret_vbox);
		$window->show();


#our main event-loop
	Gtk2->main();

sub loadAnime {
	my $num = shift;
		@{$slCompleted->{data}} = AnimeList::getCompleted($num);
		@{$slWatching->{data}} = AnimeList::getWatching($num);
		@{$slOnHold->{data}} = AnimeList::getOnHold($num);
		@{$slPTW->{data}} = AnimeList::getPTW($num);
}

sub ret_vbox {
	my $vbox = Gtk2::VBox->new(FAL,5);
	my $nb = &ret_notebook;
	my $menubar = &sortMenu;
	my $statusbar = UserStats->UserStatus;
		$statusbar->show();
		$menubar->show();
		$nb->show_all;
	
		$vbox->pack_start($menubar,FAL,FAL,0);
		$vbox->pack_start($nb,FAL,FAL,0);
		$vbox->pack_start($statusbar,FAL,FAL,0);

		$vbox->show_all();
	return $vbox;
}

sub sortMenu {
	my $menu = new Gtk2::Menu();
	
	my $menu_ID = new Gtk2::MenuItem( "ID" );
	   $menu_ID->signal_connect( 'activate', sub { loadAnime(0); } );
	my $menu_Title = new Gtk2::MenuItem( "Title" );
	   $menu_Title->signal_connect( 'activate', sub { loadAnime(1); } );
	my $menu_Type = new Gtk2::MenuItem( "Type" );
	   $menu_Type->signal_connect( 'activate', sub { loadAnime(2); } );
	my $menu_Episodes = new Gtk2::MenuItem( "Episodes" );
	   $menu_Episodes->signal_connect( 'activate', sub { loadAnime(3); } );
	  
	   $menu->append( $menu_ID );
	   $menu->append( $menu_Title );
	   $menu->append( $menu_Type );
	   $menu->append( $menu_Episodes );
	   
	   # Show the widget
	   $menu_ID->show();
	   $menu_Title->show();
	   $menu_Type->show();
	   $menu_Episodes->show();
	   
	my $root_menu = new Gtk2::MenuItem( "Sort by:" );
	   $root_menu->show();
	   $root_menu->set_submenu( $menu );
	my $menubar = new Gtk2::MenuBar();
	   $menubar->append($root_menu);
	
	return $menubar;

}

#Notebook
sub ret_notebook {
	my $vbox_nb = Gtk2::VBox->new(FAL,5);
		$vbox_nb->set_size_request (750, 750);
	my $nb = Gtk2::Notebook->new;
	
		$scrlWatching->add($slWatching);
		$scrlCompleted->add($slCompleted);
		$scrlOnHold->add($slOnHold);
		$scrlPTW->add($slPTW);
	my @LIST = ('Watching','Completed','On-Hold','Plan To Watch');
	my @CHILD = ($scrlWatching,$scrlCompleted,$scrlOnHold,$scrlPTW);
		for (0..3) {
			my $child = $CHILD[$_];	
			my $hbox = Gtk2::HBox->new(FAL,0);
				$hbox->pack_start(Gtk2::Label->new("$LIST[$_]"),FAL,FAL,0);
				$hbox->show_all;
				$nb->append_page ($child,$hbox);
		}	
			
		$vbox_nb->pack_start($nb,TRU,TRU,0);
	
	return $vbox_nb;
}

sub info_box {
	my $id = shift;
	my $FILE = "AnimeListImages/" . $id . ".jpg";
		$infoWindow->set_Window(Anime::getAnime($id),$FILE);
		$infoWindow->show();
}
