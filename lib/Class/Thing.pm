package Class::Thing;

use strict;
use warnings;
use parent qw(
    Class::Accessor::Lvalue::Fast
    Class::Data::Inheritable
    Class::ErrorHandler
);
use Hash::MultiValue;

my $dumper = 'yaml';

sub import {
    my $class = shift;
    if ( ( $_[0] || '' ) eq '-base' and shift ) {
        my %args = @_;
        my $caller = caller 0;

        $dumper = $args{dumper} if exists $args{dumper};

        strict->import;
        warnings->import;

        no strict 'refs';
        unshift @{"${caller}::ISA"}, $class;
    }
}

sub new {
    my $class = shift;
    my $self = $class->SUPER::new({@_});
    my $init = $self->can('init') || $self->can('initialize');
    $init->($self) if $init;
    return $self;
}

sub stash {
    my $self = shift;
    return $self->{__stash} ||= Hash::MultiValue->new;
}
*param = \&stash;

sub inline {
    my ($self, %args) = @_;
    return bless \%args, 'Class::Thing::Inline';
}

my $debug = 0;
sub debug : lvalue { $debug }

sub denude {
    my ($self, @args) = @_;
    @args = $self unless @args;
    # stolen from XXX.pm
    my $at_line_number = sprintf "  at %s line %d\n", ( caller 0 )[ 1, 2 ];
    if ( $dumper eq 'dumper' ) {
        require Data::Dumper;
        local $Data::Dumper::Sortkeys = 1;
        local $Data::Dumper::Indent   = 1;
        local $Data::Dumper::Terse    = 1;
        warn Data::Dumper::Dumper(\@args) . $at_line_number;
    } else {
        require YAML::XS;
        warn YAML::XS::Dump(\@args) . $at_line_number;
    }
    return $self;
}

package Class::Thing::Inline;

sub can {
    exists $_[0]->{$_[1]};
}

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    ( my $attr = $AUTOLOAD ) =~ s/.*://;
    if ( ref( $self->{$attr} ) eq 'CODE' ) {
        return $self->{$attr}->(@_);
    } else {
        return $self->{$attr};
    }
}

sub DESTROY {}

1;
