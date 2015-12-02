package WWW::AdventCalendar::Article;
BEGIN {
  $WWW::AdventCalendar::Article::VERSION = '1.000';
}
use Moose;
# ABSTRACT: one article in an advent calendar


use autodie;
use Mojo::DOM;
use WWW::AdventCalendar::MultiMarkdown;

has date => (is => 'ro', isa => 'DateTime', required => 1);
has [ qw(title package author body) ] => (is => 'ro', isa => 'Str', required => 1);


has calendar => (
  is  => 'ro',
  isa => 'WWW::AdventCalendar',
  required => 1,
  weak_ref => 1,
);


has body_html => (
  is   => 'ro',
  lazy => 1,
  init_arg => undef,
  builder  => '_build_body_html',
);

sub _build_body_html {
  my ($self) = @_;

  my $body = $self->body;

  my $m = WWW::AdventCalendar::MultiMarkdown->new(
      tab_width     => 2,
      use_wikilinks => 0,
  );
  my $html = $m->markdown( $body );

  return $html;
}

sub atom_id {
  my ($self) = @_;

  return $self->calendar->uri . $self->date->ymd . '.html';
}

sub description {
  my ($self) = @_;

  my @desc;
  my $dom = Mojo::DOM->new( '<div id="root">' . $self->body_html . '</div>' );
  for ( my $e = $dom->find('h2')->[1]->next; $e; $e = $e->next ) {
    last if $e->tag eq 'h2';
    push @desc, $e->all_text;
  }

  return join( "\n", @desc );
}

1;

__END__
=pod

=head1 NAME

WWW::AdventCalendar::Article - one article in an advent calendar

=head1 VERSION

version 1.000

=head1 DESCRIPTION

Objects of this class represent a single article in a L<WWW::AdventCalendar>.
They have a very limited set of attributes.  The primary task of this class is
the production of an HTML version of the article's body.

=head1 ATTRIBUTES

=head2 date

This is the date (a DateTime object) on which the article is to be published.

=head2 title

This is the title of the article.

=head2 package

This is the Perl package that the article describes.  This attribute is
required, for now, but may become optional in the future.

=head2 body

This is the body of the document, as a string.  It is expected to be Pod.

=head2 calendar

This is the WWW::AdventCalendar object in which the article is found.

=head2 body_html

This is the body represented as HTML.  It is generated as required by a private
builder method.

=head1 AUTHOR

Ricardo SIGNES <rjbs@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Ricardo SIGNES.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

