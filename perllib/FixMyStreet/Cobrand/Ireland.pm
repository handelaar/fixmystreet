package FixMyStreet::Cobrand::Ireland;
use base 'FixMyStreet::Cobrand::Default';

use strict;
use warnings;

use Carp;
use mySociety::MaPit;
use Math::BaseCalc;


sub country {
    return 'IE';
}

sub shorturl {
    my $self = shift;
    my ($id) = @_;
    my $base10 = new Math::BaseCalc(digits=>[0..9]);
    my $base62 = new Math::BaseCalc(digits=>['A'..'Z',0..9,'a'..'z']);
    my $shorten = $base62->to_base ($id);
    return $shorten;
}

sub set_lang_and_domain {
    my ( $self, $lang, $unicode, $dir ) = @_;
    my $set_lang = mySociety::Locale::negotiate_language(
        'en-gb,English,en_GB', 'en-gb'
    );
    mySociety::Locale::gettext_domain( 'FixMyStreet', $unicode, $dir );
    mySociety::Locale::change();
    return $set_lang;
}

sub short_name {
  my $self = shift;
  my ($area, $info) = @_;
  my $name = $area->{name};
  $name =~ s/ County Council$//;
  $name =~ s/ Council$//;
  $name =~ s/ & / and /;
  $name =~ s{/}{_}g;
  $name = URI::Escape::uri_escape_utf8($name);
  $name =~ s/%20/+/g;
  return $name;

}

sub council_child_types { 
        return qw(ICC ITC);
}

sub council_parent_types { 
        return qw(ICO ITO);
}

sub site_title {
    my ($self) = @_;
    return 'FixMyStreet Ireland';
}

sub enter_postcode_text {
    my ( $self ) = @_;
    return _('Enter a nearby street name, area or townland');
}

# Is also adding language parameter
sub disambiguate_location {
    return {
        lang => 'en-ie',
        country => 'ie',
    };
}

sub area_types {
    return ( 'ICO' );
}

sub area_min_generation {
    return '';
}

sub admin_base_url {
    return 'http://fixmy.st/admin/';
}

# If lat/lon are present in the URL, OpenLayers will use that to centre the map.
# Need to specify a zoom to stop it defaulting to null/0.
sub uri {
    my ( $self, $uri ) = @_;

    $uri->query_param( zoom => 3 )
      if $uri->query_param('lat') && !$uri->query_param('zoom');

    return $uri;
}

sub geocoded_string_check {
    my ( $self, $s ) = @_;
    return 1 if $s =~ /, Ireland/;
    return 0;
}


1;
