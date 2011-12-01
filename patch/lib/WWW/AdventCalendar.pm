package WWW::AdventCalendar;
BEGIN {
  $WWW::AdventCalendar::VERSION = '1.000';
}
use Moose;
# ABSTRACT: a calendar for a month of articles (on the web)

use autodie;
use Calendar::Simple;
use DateTime;
use DateTime::Format::W3CDTF;
use Email::Simple;
use File::Copy qw(copy);
use File::Path 2.07 qw(remove_tree);
use DateTime;
use File::Basename;
use HTML::Mason::Interp;
use Path::Class ();
use XML::Atom::SimpleFeed;
use WWW::AdventCalendar::Article;


has title  => (is => 'ro', required => 1);
has uri    => (is => 'ro', required => 1);
has editor => (is => 'ro', required => 1);
has year   => (is => 'ro', required => 1);
has categories => (is => 'ro', default => sub { [ qw() ] });

has article_dir => (is => 'rw', required => 1);
has share_dir   => (is => 'rw', required => 1);
has output_dir  => (is => 'rw', required => 1);

has today      => (is => 'rw');

has tracker_id => (is => 'ro');

sub _masonize {
  my ($self, $comp, $args) = @_;

  my $str = '';

  my $interp = HTML::Mason::Interp->new(
    comp_root  => $self->share_dir->subdir('templates')->absolute->stringify,
    out_method => \$str,
  );

  $interp->exec($comp, tracker_id => $self->tracker_id, %$args);

  return $str;
}

sub _parse_isodate {
  my ($date, $time_from) = @_;

  my ($y, $m, $d) = $date =~ /\A([0-9]{4})-([0-9]{2})-([0-9]{2})\z/;
  die "can't parse date: $date\n" unless $y and $m and $d;

  $time_from ||= [ (0) x 10 ];

  return DateTime->new(
    year   => $y,
    month  => $m,
    day    => $d,
    hour   => $time_from->[2],
    minute => $time_from->[1],
    second => $time_from->[0],
    time_zone => 'local',
  );
}

sub BUILD {
  my ($self) = @_;

  $self->today(
    $self->today
    ? _parse_isodate($self->today, [localtime])
    : DateTime->now(time_zone => 'local')
  );

  for (map { "$_\_dir" } qw(article output share)) {
    $self->$_( Path::Class::Dir->new($self->$_) );
  }
}


sub build {
  my ($self) = @_;

  $self->output_dir->rmtree;
  $self->output_dir->mkpath;

  my $share = $self->share_dir;
  copy "$_" => $self->output_dir
    for grep { ! $_->is_dir } $self->share_dir->subdir('static')->children;

  my $feed = XML::Atom::SimpleFeed->new(
    title   => $self->title,
    id      => $self->uri,
    link    => {
      rel  => 'self',
      href => $self->uri . 'atom.xml',
    },
    updated => $self->_w3cdtf($self->today),
    author  => $self->editor,
  );

  my %dec;
  for (1 .. 31) {
    $dec{$_} = DateTime->new(
      year  => $self->year,
      month => 12,
      day   => $_,
      time_zone => 'local',
    );
  }

  if ($dec{1} > $self->today) {
    my $dur  = $dec{1} - $self->today;
    my $days = $dur->delta_days + 1;
    my $str  = $days != 1 ? "$days days" : "1 day";

    $self->output_dir->file("index.html")->openw->print(
      $self->_masonize('/patience.mhtml', {
        days => $str,
        year => $self->year,
      }),
    );

    $feed->add_entry(
      title     => $self->title . " is Coming",
      link      => $self->uri,
      id        => $self->uri,
      summary   => "The first door opens in $str...\n",
      updated   => $self->_w3cdtf($self->today),

      (map {; category => $_ } @{ $self->categories }),
    );

    $feed->print( $self->output_dir->file('atom.xml')->openw );

    return;
  }

  my $article = $self->read_articles;

  {
    my $d = $dec{1};
    while (
      $d->ymd le (sort { $a cmp $b } ($dec{26}->ymd, $self->today->ymd))[0]
    ) {
      warn "no article written for " . $d->ymd . "!\n"
        unless $article->{ $d->ymd };

      $d = $d + DateTime::Duration->new(days => 1 );
    }
  }

  $self->output_dir->file('index.html')->openw->print(
    $self->_masonize('/calendar.mhtml', {
      today  => $self->today,
      year   => $self->year,
      month  => \%dec,
      calendar => scalar calendar(12, $self->year),
      articles => $article,
    }),
  );

  my @dates = sort keys %$article;
  for my $i (0 .. $#dates) {
    my $date = $dates[ $i ];

    my $output;

    print "processing article for $date...\n";
    $self->output_dir->file("$date.html")->openw->print(
      $self->_masonize('/article.mhtml', {
        article => $article->{ $date },
        date    => $date,
        next    => ($i < $#dates ? $article->{ $dates[ $i + 1 ] } : undef),
        prev    => ($i > 0       ? $article->{ $dates[ $i - 1 ] } : undef),
        year    => $self->year,
      }),
    );
  }

  for my $date (reverse @dates){
    my $article = $article->{ $date };

    $feed->add_entry(
      title     => HTML::Entities::encode_entities($article->title),
      link      => $self->uri . "$date.html",
      id        => $article->atom_id,
      summary   => Encode::decode('utf-8', $article->body_html),
      updated   => $self->_w3cdtf($article->date),
      author    => $article->author,
      (map {; category => $_ } @{ $self->categories }),
    );
  }

  $feed->print( $self->output_dir->file('atom.xml')->openw );
}

sub _w3cdtf {
  my ($self, $datetime) = @_;
  DateTime::Format::W3CDTF->new->format_datetime($datetime);
}


sub read_articles {
  my ($self) = @_;

  my %article;

  for my $file (grep { ! $_->is_dir && $_->basename !~ /swp$/ } $self->article_dir->children) {
    my ($name, $path) = fileparse($file);
    $name =~ s{\..+\z}{}; # remove extension

    open my $fh, '<', $file;
    my $content = do { local $/; <$fh> };
    my $document = Email::Simple->new($content);
    my $isodate  = $name;

    die "no title set in $file\n" unless $document->header('title');
    die "no author set in $file\n" unless $document->header('author');

    my $article  = WWW::AdventCalendar::Article->new(
      body  => $document->body,
      date  => _parse_isodate($isodate),
      title => $document->header('title'),
      package  => $document->header('package'),
      calendar => $self,
      author => $document->header('author'),
    );

    next unless $article->date < $self->today;

    die "already have an article for " . $article->date->ymd
      if $article{ $article->date->ymd };

    $article{ $article->date->ymd } = $article;
  }

  return \%article;
}

1;

__END__
=pod

=head1 NAME

WWW::AdventCalendar - a calendar for a month of articles (on the web)

=head1 VERSION

version 1.000

=head1 DESCRIPTION

This is a library for producing Advent calendar websites.  In other words, it
makes four things:

=over 4

=item *

a page saying "first door opens in X days" until Dec 1

=item *

a calendar page on and after Dec 1

=item *

a page for each day in December with an article

=item *

an Atom feed

=back

This library may be generalized somewhat in the future.  Until then, it should
work for at least December for every year.  It has only been tested for 2009,
which may be of limited utility going forward.

=head1 OVERVIEW

To build an Advent calendar:

=over 4

=item 1

create an advent.ini configuration file

=item 2

write articles and put them in a directory

=item 3

schedule F<advcal> to run nightly

=back

F<advent.ini> is easy to produce.  Here's the one used for the original RJBS
Advent Calendar:

  title  = RJBS Advent Calendar
  year   = 2009
  uri    = http://advent.rjbs.manxome.org/
  editor = Ricardo Signes
  category = Perl
  category = RJBS

  article_dir = rjbs/articles
  share_dir   = share

These should all be self-explanatory.  Only C<category> can be provided more
than once, and is used for the category listing in the Atom feed.

These settings all correspond to L<calendar attributes/ATTRIBUTES> described
below.

Articles are easy, too.  They're just files in the C<article_dir>.  They begin
with an email-like set of headers, followed by a body written in Pod.  For
example, here's the beginning of the first article in the original calendar:

  Title:  Built in Our Workshop, Delivered in Your Package
  Package: Sub::Exporter

  =head1 Exporting

  In Perl, we organize our subroutines (and other stuff) into namespaces called
  packages.  This makes it easy to avoid having to think of unique names for

The two headers seen above, title and package, are the only headers required,
and correspond to those attributes in the L<WWW::AdventCalendar::Article>
object created from the article file.

Finally, running L<advcal> is easy, too.  Here is its usage:

  advcal [-aot] [long options...]
    -c --config       the ini file to read for configuration
    -a --article-dir  the root of articles
    --share-dir       the root of shared files
    -o --output-dir   output directory
    --today           the day we treat as "today"; default to today

    -t --tracker      include Google Analytics; -t TRACKER-ID

Options given on the command line override those loaded form configuration.  By
running this program every day, we cause the calendar to be rebuilt, adding any
new articles that have become available.

=head1 METHODS

=head2 build

  $calendar->build;

This method does all the work: it reads in the articles, decides how many to
show, writes out the rendered pages, the index, and the atom feed.

=head2 read_articles

  my $article = $calendar->read_articles;

This method reads in all the articles for the calendar and returns a hashref.
The keys are dates (in the format C<YYYY-MM-DD>) and the values are
L<WWW::AdventCalendar::Article> objects.

=head1 ATTRIBUTES

=over 4

=item title

The title of the calendar, to be used in headers, the feed, and so on.

=item uri

The base URI of the calendar, including trailing slash.

=item editor

The name of the calendar's editor, used in the feed.

=item year

The year being calendared.

=item categories

An arrayref of category names for use in the feed.

=item article_dir

The directory in which articles can be found, with names like
F<YYYY-MM-DD.html>.

=item share_dir

The directory for templates, stylesheets, and other static content.

=item output_dir

The directory into which output files will be written.

=item today

The date to treat as "today" when deciding how much of the calendar to publish.

=item tracker_id

A Google Analytics tracker id.  If given, each page will include analytics.

=back

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

