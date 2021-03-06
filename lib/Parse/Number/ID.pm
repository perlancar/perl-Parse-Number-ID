package Parse::Number::ID;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(parse_number_id $Pat);

our %SPEC;

#our $Pat = qr/(?:
#                  [+-]?
#                  (?:
#                      \d{1,2}(?:[.]\d{3})*(?:[,]\d*)? | # indo
#                      \d{1,2}(?:[,]\d{3})*(?:[.]\d*)? | # english
#                      [,.]\d+ |
#                      \d+
#                  )
#                  (?:[Ee][+-]?\d+)?
#              )/x;

# non /x version
our $Pat = '(?:[+-]?(?:\d{1,2}(?:[.]\d{3})*(?:[,]\d*)?|\d{1,2}(?:[,]\d{3})*(?:[.]\d*)?|[,.]\d+|\d+)(?:[Ee][+-]?\d+)?)';

sub _clean_nd {
    my $n = shift;
    $n =~ s/\D//;
    $n;
}

sub _parse_mantissa {
    my $n = shift;
    if ($n =~ /^([+-]?)([\d,.]*)\.(\d{0,2})$/) {
        return (_clean_nd($2 || 0) + "0.$3")*
            ($1 eq '-' ? -1 : 1);
    } else {
        $n =~ s/\.//g;
        $n =~ s/,/./g;
        no warnings;
        return $n+0;
    }
}

$SPEC{parse_number_id} = {
    v => 1.1,
    summary => 'Parse number from Indonesian text',
    args    => {
        text => {
            summary => 'The input text that contains number',
            schema => 'str*',
            pos => 0,
            req => 1,
        },
    },
    result_naked => 1,
};
sub parse_number_id {
    my %args = @_;
    my $text = $args{text};

    $text =~ s/^\s+//s;
    return undef unless length($text);

    $text =~ s/^([+-]?[0-9,.]+)// or return undef;
    my $n = _parse_mantissa($1);
    return undef unless defined $n;
    if ($text =~ /[Ee]([+-]?\d+)/) {
        $n *= 10**$1;
    }
    $n;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Parse::Number::ID qw(parse_number_id);

 my @a = map {parse_number_id(text=>$_)}
     ("12.345,67", "-1,2e3", "x123", "1.23");
 # @a = (12345.67, -1200, undef, 1.23)


=head1 DESCRIPTION

The goal of this module is to parse/extract numbers commonly found in Indonesian
text. It currently parses numbers according to Indonesian rule of decimal- and
thousand separators ("," and "." respectively) I<as well as> English ("." and
","), since English numbers are more widespread and sometimes mixed within.

 12.3     # 12.3
 12.34    # 12.34
 12.345   # 12345

In the future this module might also parse fractions (e.g. 1/3, 2 1/2) and
percentages (e.g. 1,2%).

This module does not parse numbers that are written as Indonesian words, e.g.
"seratus dua puluh tiga" (123). See L<Lingua::ID::Words2Nums> and
L<Regexp::ID::NumVerbage> for that.


=head1 VARIABLES

None are exported by default, but they are exportable.

=head2 $Pat (regex)

A regex for quickly matching/extracting number from text. It's not 100% perfect
(the extracted number might not be valid), but it's simple and fast.


=head1 FAQ

=head2 How does this module differ from other number-parsing modules?

This module uses a single regex and provides the regex for you to use. Other
modules might be more accurate and/or faster. But this module is pretty fast.

Also, since English text are often found in Indonesian text, parsing English
numbers (which uses periods for decimals and commas for thousand separators
instead of the other way around) is also done, as long as it is not ambiguous.


=head1 SEE ALSO

L<Lingua::ID::Words2Nums>

=cut
