package FixMyStreet::Cobrand::FiksGataMi;
use base 'FixMyStreet::Cobrand::Default';

use strict;
use warnings;

use Carp;
use mySociety::MaPit;
use FixMyStreet::Geocode::OSM;

sub country {
    return 'IE';
}

sub set_lang_and_domain {
    my ( $self, $lang, $unicode, $dir ) = @_;
    my $set_lang = mySociety::Locale::negotiate_language(
        'en-gb,English,en_GB|en-ie,English,en_IE|', 'en-ie'
    );
    mySociety::Locale::gettext_domain( 'Ireland', $unicode, $dir );
    mySociety::Locale::change();
    return $set_lang;
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

sub geocode_postcode {
    my ( $self, $s ) = @_;

    if ($s =~ /^\d{4}$/) {
        my $location = mySociety::MaPit::call('postcode', $s);
        if ($location->{error}) {
            return {
                error => $location->{code} =~ /^4/
                    ? _('That postcode was not recognised, sorry.')
                    : $location->{error}
            };
        }
        return {
            latitude  => $location->{wgs84_lat},
            longitude => $location->{wgs84_lon},
        };
    }
    return {};
}

sub geocoded_string_check {
    my ( $self, $s ) = @_;
    return 1 if $s =~ /, Ireland/;
    return 0;
}

sub find_closest {
    my ( $self, $latitude, $longitude ) = @_;
    return FixMyStreet::Geocode::OSM::closest_road_text( $self, $latitude, $longitude );
}


1;
