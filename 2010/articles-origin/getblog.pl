#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use autodie;

use WWW::Mechanize;
use Web::Scraper;
use Data::Dumper;
use URI;
use URI::Escape;
use EBook::EPUB;
use Image::Info qw/image_info/;
use File::Basename qw/ basename /;
use WWW::Instapaper::Client;

my $email        = 'your@email.com';
my $password     = 'your_password';
my $creator      = $email;
my $author       = $email;
my $result_html  = 'result.html';
my $result_ebook = 'myebook.epub';

#my $title ='Perl-Acme-大全-Perl-동인문화의-결정체';
my ( undef $title );

#my $url ='http://aero2blog.blogspot.com/2010/11/modern-perl.html';
my ( undef $url );
my $mech              = WWW::Mechanize->new();
my $instapaper_unread = 'http://www.instapaper.com/u';
my $instapaper_login  = 'http://www.instapaper.com/user/login';

my $paper = WWW::Instapaper::Client->new(
    username => $email,
    password => $password,
);

my $result = $paper->add(
    url       => shift,
    title     => shift,
    selection => '',
);

if ( defined $result ) {
    $url   = $result->[0];
    $title = $result->[1];
}
else {
    warn $paper->error . "\n";
    exit;
}

say $url;
my $res = $mech->get($instapaper_login);
if ( $mech->success() ) {
    my $form = $mech->current_form();
    $form->value( username => $email );
    $form->value( password => $password );
    $res = $mech->submit();
    if ( $res->is_success() ) {
        $res = $mech->get($instapaper_unread);
        $url = URI->new($url)->as_string();
        $url =~ s/([^A-Za-z0-9-.])/sprintf("%%%02X", ord($1))/seg;
        if ( $res->decoded_content =~ /href="(\/text\?u=$url&article=\d+)/ ) {
            $res = $mech->get( 'http://instapaper.com' . $1 );
            my $download_link = scraper {
                process 'img', 'link[]' => '@src';
            };

            my $content = $res->decoded_content;
            for my $link ( @{ $result->{link} } ) {
                my $filename = basename($link);
                $content =~ s/$link/$filename/;
            }
            open my $fh, '>', $result_html;
            binmode $fh;
            print $fh $content;
            close $fh;

            download( $result->{link} );
            epub( $result->{link} );

        }
    }
}

sub download {
    my $links = shift;
    for my $link (@$links) {
        my $ua       = LWP::UserAgent->new();
        my $filename = basename($link);
        $res = $ua->get($link);
        if ( $res->is_success() ) {
            open my $fh, '>', $filename;
            binmode $fh;
            print $fh $res->content;
            close $fh;
        }
    }
}

sub epub {
    my $links = shift;
    my $epub  = EBook::EPUB->new;
    $epub->add_title($title);
    $epub->add_author($author);
    $epub->add_language('ko');
    $epub->add_identifier( '9999999999', 'ISBN' );
    for my $img (@$links) {
        my $el     = basename($img);
        my $result = image_info($el);
        if ( !defined( $result->{error} ) ) {
            my $filetype = $result->{file_media_type};
            print $el. ' ' . $filetype . "\n";
            $epub->copy_image( $el, $el, $filetype );
        }
    }
    $epub->copy_xhtml( $result_html, $result_html );
    $epub->pack_zip($result_ebook);
}
