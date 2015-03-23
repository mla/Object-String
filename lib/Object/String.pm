use strict;
use warnings;
use utf8;
use v5.10;

package Object::String;
use Unicode::Normalize;
use List::Util;

# VERSION

# ABSTRACT: A string object for Perl 5

use Moo;
use namespace::clean;

=head1 DESCRIPTION

A string object for Perl 5.

C<Object::String> have a lot of "modern" features and supports method chaining. A helper is also provided to 
help to build a string object.

C<Object::String> is heavily inspired by stringjs a Ruby string object.

    # Normal way to build a string object
    my $string = Object::String->new(string => 'test');

    # With the helper
    my $string = str('test');

    # Display the string
    say $string->string;

    # Method chaining 
    say $string->chomp_right->to_upper->string;
    say str('testZ')->chop_right->to_upper->string; # TEST

=cut

=method string

Converts the object into a string scalar.
Aliases: C<to_string>
=cut

has 'string' => ( is => 'ro' );

=method to_string

An alias to C<string>.

=cut

sub to_string { shift->string; }

=method to_lower

Converts the string to lower case.

    say str('TEST')->to_lower->string; # test

=cut

sub to_lower {
    my $self = shift;
    $self->{string} = lc $self->{string};
    return $self;
}

=method to_lower_first

Lower case the first letter of a string.

    say str('TEST')->to_lower_first->string; # tEST

=cut

sub to_lower_first {
    my $self = shift;
    $self->{string} = lcfirst $self->{string};
    return $self;
}

=method to_upper

Converts the string to upper case.

    say str('test')->to_upper->string; # TEST

=cut

sub to_upper {
    my $self = shift;
    $self->{string} = uc $self->{string};
    return $self;
}

=method to_upper_first

Upper case the first letter of a string.

    say str('test')->to_upper_first->string; # Test

=cut

sub to_upper_first {
    my $self = shift;
    $self->{string} = ucfirst $self->{string};
    return $self;
}

=method capitalize

Capitalizes a string.

    say str('TEST')->capitalize->string; # Test

=cut

sub capitalize { shift->to_lower->to_upper_first; }

=method length

Returns the length of a string.

    say str('test')->length; # 4

=cut

sub Object::String::length { return CORE::length shift->string; }

=method ensure_left($prefix)

Ensures the string is beginning with C<$prefix>.

    say str('dir')->ensure_left('/')->string;   # /dir
    say str('/dir')->ensure_left('/')->string;  # /dir

=cut

sub ensure_left {
    my ($self, $prefix) = @_;
    $self->{string} = $self->prefix($prefix)->string 
        unless($self->starts_with($prefix));     
    return $self;
}

=method ensure_right($suffix)

Ensures the string is ending with C<$suffix>.

    say str('/dir')->ensure_right('/')->string;     # /dir/
    say str('/dir/')->ensure_right('/')->string;    # /dir/

=cut

sub ensure_right {
    my ($self, $suffix) = @_;
    $self->{string} = $self->suffix($suffix)->string 
        unless($self->ends_with($suffix));
    return $self;
}

=method trim_left

Trim string from left.

    say str("  \t test")->trim_left->string; # test

=cut

sub trim_left {
    my $self = shift;
    $self->{string} =~ s/^(\s|\t)+//;
    return $self;
}

=method trim_right

Trim string from right.

    say str("test \t   \t")->trim_right->string; # test

=cut

sub trim_right {
    my $self = shift;
    $self->{string} =~ s/(\s|\t)+$//;
    return $self;
}

=method trim

Trim string from left and from right.

    say str("\t  \ttest \t\t")->trim->string; # test

=cut

sub trim { shift->trim_left->trim_right; }

=method clean

Deletes unuseful whitespaces.

    say str("This\t   \tis  \t a     \t test")->clean->string; # This is a test

Aliases: C<collapse_whitespace>

=cut

sub clean { 
    my $self = shift;
    $self->{string} =~ s/(\s|\t)+/ /g;
    return $self->trim;
}

=method collapse_whitespace

An alias to C<clean>.

=cut

sub collapse_whitespace { shift->clean; }

=method repeat($n)

Repeats a string C<$n> times.
Aliases: C<times>

    say str('test')->repeat(3)->string; # testtesttest

=cut

sub repeat {
    my ($self, $n) = @_;
    $self->{string} = $self->string x $n;
    return $self;
}

=method times($n)

An alias to C<repeat>.

=cut

sub times { shift->repeat(@_); }

=method starts_with($str)

Tests if the string starts with C<$str>.

    str('test')->starts_with('te');     # true
    str('test')->starts_with('z');      # false

=cut

sub starts_with {
    my ($self, $str) = @_;
    return ($self->string =~ /^$str/);
}

=method ends_with($str)

Tests if the string ends with C<$str>.

    str('test')->ends_with('st');   # true
    str('test')->ends_with('z');    # false

=cut

sub ends_with {
    my ($self, $str) = @_;
    return ($self->string =~ /$str$/);
}

=method contains($str)

Tests if the string contains C<$str>.
Aliases: C<include>

    str('test')->contains('es');    # true
    str('test')->contains('z');     # false

=cut

sub contains {
    my ($self, $str) = @_;
    return index $self->string, $str;
}

=method include($str)

An alias to C<contains>.

=cut

sub include { shift->contains(@_); }

=method chomp_left

Chomp left the string. If the string begins by a space or a tab, it is removed.

=cut

sub chomp_left { 
    my $self = shift;
    if($self->starts_with(" ") || $self->starts_with("\t")) {
        return $self->chop_left;
    }
    return $self;
}

=method chomp_right

Chomp right the string. Same as the Perl's C<chomp> function.

=cut

sub chomp_right {
    my $self = shift;
    if($self->ends_with(" ") || $self->ends_with("\t")) {
        return $self->chop_right;
    }
    return $self;
}

=method chop_left

Deletes the first character of the string.

    say str('test')->chop_left->string; # est

=cut

sub chop_left {
    my $self = shift;
    $self->{string} = substr $self->{string}, 1, CORE::length $self->{string};
    return $self;

}

=method chop_right

Deletes the last character of the string. Same function as Perl's C<chop> function.

    say str('test')->chop_right->string; # tes

=cut

sub chop_right {
    my $self = shift;
    chop $self->{string};
    return $self;
}

=method is_numeric

Tests if the string is composed by numbers.

    str('123')->is_numeric;     # true
    str('1.23')->is_numeric;    # false
    str('ab1')->is_numeric;     # false

=cut

sub is_numeric { shift->string =~ /^\d+$/; }

=method is_alpha

Tests if the string is composed by alphabetic characters.

    str('abc')->is_alpha;       # true
    str('a1b2c3')->is_alpha;    # false

=cut

sub is_alpha { shift->string =~ /^[a-zA-Z]+$/; }

=method is_alpha_numeric

Tests if the string is composed only by letters and numbers.

    str('abc')->is_alpha_numeric;       # true
    str('a1b2c3')->is_alpha_numeric;    # true
    str('1.3e10')->is_alpha_numeric;    # false

=cut

sub is_alpha_numeric { shift->string =~ /^[a-zA-Z0-9]+$/; }

=method is_lower

Tests if a string is lower case.

    str('TEST')->is_lower; # false
    str('test')->is_lower; # true

=cut

sub is_lower {
    my $self = shift;
    return $self->string eq lc $self->string;
}

=method is_upper

Tests if the string is upper case.

    str('TEST')->is_upper; # true
    str('test')->is_upper; # false

=cut

sub is_upper {
    my $self = shift;
    return $self->string eq uc $self->string;
}

=method to_boolean

Returns a boolean if the string is ON|OFF, YES|NO, TRUE|FALSE upper or lower case.
Aliases: C<to_bool>

    str('on')->to_boolean;      # true
    str('off')->to_boolean;     # false
    str('yes')->to_boolean;     # true
    str('no')->to_boolean;      # false
    str('true')->to_boolean;    # true
    str('false')->to_boolean;   # false
    str('test')->to_boolean;    # undef

=cut

sub to_boolean {
    my $self = shift;
    return 1 if $self->string =~ /^(on|yes|true)$/i;
    return 0 if $self->string =~ /^(off|no|false)$/i;
    return;
}

=method to_bool

An alias to C<to_boolean>.

=cut

sub to_bool { shift->to_boolean }

=method is_empty

Tests if a string is empty. 

    str('')->is_empty;          # true
    str('   ')->is_emtpy;       # true
    str("  \t\t  ")->is_empty;  # true
    str("aaa")->is_empty;       # false

=cut

sub is_empty {
    my $self = shift;
    return 1 if $self->string =~ /\s+/ || $self->string eq '';
    return 0;
}

=method count($str)

Counts the occurrences of C<$str> in the string.

    say str('This is a test')->count('is'); # 2

=cut

sub count {
    my ($self, $str) = @_;
    return () = $self->string =~ /$str/g;
}

=method left($count)

Returns a substring of C<$count> characters from the left.

    say str('This is a test')->left(3)->string;     # Thi
    say str('This is a test')->left(-3)->string;    # est

=cut

sub left {
    my ($self, $count) = @_;
    if($count < 0) { 
        $self->{string} = substr $self->string, $count, abs($count); 
        return $self;
    }
    $self->{string} = substr $self->string, 0, $count;
    return $self;
}

=method right($count)

Returns a substring of C<$count> characters from the right.

    say str('This is a test')->right(3)->string;    # est
    say str('This is a test')->right(-3)->string;   # Thi

=cut

sub right {
    my ($self, $count) = @_;
    if($count < 0) { 
        $self->{string} = substr $self->string, 0, abs($count); 
        return $self;
    }
    $self->{string} = substr $self->string, -$count, $count;
    return $self;
}

=method underscore

Converts the string to snake case.
Aliases: C<underscored>

    say str('thisIsATest')->underscore->string;     # this_is_a_test
    say str('ThisIsATest')->underscore->string;     # _this_is_a_test
    say str('This::IsATest')->underscore->string;   # _this/is_a_test
    say str('This Is A Test')->underscore->string;  # this_is_a_test

=cut

sub underscore {
    my $self = shift;
    $self->{string} = $self->transliterate(' -', '_')->string;
    $self->{string} =~ s/::/\//g;
    $self->{string} =~ s/^([A-Z])/_$1/;
    $self->{string} =~ s/([A-Z]+)([A-Z][a-z])/$1_$2/g;
    $self->{string} =~ s/([a-z\d])([A-Z])/$1_$2/g;
    return $self->to_lower;
}

=method underscored

An alias to underscore.

=cut

sub underscored { shift->underscore; }

=method dasherize

Converts the string to a dasherized one.

    say str('thisIsATest')->dasherize->string;      # thisr-is-a-test
    say str('ThisIsATest')->dasherize->string;      # -this-is-a-test
    say str('This::IsATest')->dasherize->string;    # -this/is-a-test
    say str('This Is A Test')->dasherize->string;   # this-is-a-test

=cut

sub dasherize { shift->underscore->transliterate('_', '-'); }

=method camelize

Converts the string to a camelized one.

    say str('this-is-a-test')->camelize->string;    # thisIsATest
    say str('_this_is_a_test')->camelize->string;   # ThisIsATest
    say str('_this/is/a-test')->camelize->string;   # This::Is::ATest
    say str('this is a test')->camelize->string;    # thisIsATest

=cut

sub camelize {
    my $self = shift;
    my $begins_underscore = $self->underscore->starts_with('_');
    $self->{string} = join '', map { ucfirst $_ } split /_/, $self->underscore->string;
    $self->{string} = join '::', map { ucfirst $_ } split /\//, $self->string;
    return ($begins_underscore ? $self : $self->to_lower_first);
}

=method latinise

Removes accents from Latin characters.

    say str('où es-tu en été ?')->latinise->string; # ou es-tu en ete ?

=cut

sub latinise {
    my $self = shift;
    $self->{string} = NFKD($self->string);
    $self->{string} =~ s/\p{NonspacingMark}//g;
    return $self;
}

=method escape_html

Escapes some HTML entities : &"'<>

    # &lt;h1&gt;l&#39;été sera beau &amp; chaud&lt;/h1&gt;
    say str("<h1>l'été sera beau & chaud</h1>")->escape_html->string;

    #&lt;h1&gt;entre &quot;guillemets&quot;&lt;/h1&gt;
    say str('<h1>entre "guillemets"</h1>')->escape_html->string    

=cut

sub escape_html {
    return shift->replace_all('&', '&amp;')
                ->replace_all('"', '&quot;')
                ->replace_all("'", '&#39;')
                ->replace_all('<', '&lt;')
                ->replace_all('>', '&gt;');
}

=method unescape_html

Unescapes some HTML entities : &"'<>

=cut

sub unescape_html {
    return shift->replace_all('&amp;', '&')
                ->replace_all('&quot;', '"')
                ->replace_all('&#39;', "'")
                ->replace_all('&lt;', '<')
                ->replace_all('&gt;', '>');
}

=method index_left($substr[, $position])

Searches for a substring within another from a position. If C<$position> is
not specified, it begins from 0.

    say str('this is a test')->index_left('is');        # 2
    say str('this is a test')->index_right('is', 3);    # 5

=cut

sub index_left {
    my ($self, $substr, $position) = @_;
    return index $self->string, $substr, $position if defined $position;
    return index $self->string, $substr;
}

=method index_right($substr[, $position])

Searches from right for a substring within another from a position. If C<$position> 
is not specified, it begins from 0.

    say str('this is a test')->index_right('is');       # 5
    say str('this is a test')->index_right('is', 5);    # 2

=cut

sub index_right {
    my ($self, $substr, $position) = @_;
    return rindex $self->string, $substr, $position if defined $position;
    return rindex $self->string, $substr;
}

=method replace_all($substr1, $substr2)

Replaces all occurrences of a substring within the string.

    say str('This is a test')->replace_all(' ', '_'); # this_is_a_test

=cut 

sub replace_all {
    my ($self, $substr1, $substr2) = @_;
    $substr1 = quotemeta $substr1;
    $self->{string} =~ s/$substr1/$substr2/g;
    return $self;
}

=method humanize

Transforms the input into a human friendly form.

    say str('-this_is a test')->humanize->string; # This is a test

=cut

sub humanize {
    return shift->underscore
                ->replace_all('_', ' ')
                ->trim
                ->capitalize;
}

=method pad_left($count[, $char])

Pad left the string with C<$count> C<$char>. 
If C<$char> is not specified, a space is used.

    say str('hello')->pad_left(3)->string;          # hello
    say str('hello')->pad_left(5)->string;          # hello
    say str('hello')->pad_left(10)->string;         #      hello
    say str('hello')->pad_left(10, '.')->string;    # .....hello

=cut

sub pad_left {
    my ($self, $count, $char) = @_;
    $char = ' ' unless defined $char;
    return $self if $count <= $self->length;
    $self->{string} = $char x ($count - $self->length) . $self->string;
    return $self;
}

=method pad_right($count[, $char])

Pad right the string with C<$count> C<$char>.
If C<$char> is not specified, a space is used.

    say str('hello')->pad_right(3)->string;         # hello
    say str('hello')->pad_right(5)->string;         # hello
    say str('hello')->pad_right(10)->string;        # "hello     "
    say str('hello')->pad_left(10, '.')->string;    # hello.....

=cut

sub pad_right {
    my ($self, $count, $char) = @_;
    $char = ' ' unless defined $char;
    return $self if $count <= $self->length;
    $self->{string} = $self->string . $char x ($count - $self->length);
    return $self;
}

=method pad($count[, $char])

Pad the string with C<$count> C<$char>.
If C<$char> is not specified, a space is used.

    say str('hello')->pad(3)->string;       # hello
    say str('hello')->pad(5)->string;       # hello
    say str('hello')->pad(10)->string;      # "   hello  "
    say str('hello')->pad(10, '.')->string; # ...hello..

=cut

sub pad {
    my ($self, $count, $char) = @_;
    $char = ' ' unless defined $char;
    return $self if $count <= $self->length;
    my $count_left = 1 + int(($count - $self->length) / 2);
    my $count_right = $count - $self->length - $count_left;
    $self->{string} = $char x $count_left . $self->string;
    $self->{string} = $self->string . $char x $count_right;
    return $self;
}

=method next

Increments the string.

    say str('a')->next->string; # b
    say str('z')->next->string; # aa

=cut

sub next {
    my $self = shift;
    $self->{string}++;
    return $self;
}

=method slugify

Transfoms the input into an url slug.

    say str('En été, il fera chaud')->slugify->string; # en-ete-il-fera-chaud

=cut

sub slugify {
    return shift->trim
                ->humanize
                ->latinise
                ->strip_punctuation
                ->to_lower
                ->dasherize;
}

=method strip_punctuation

Strips punctuation from the string.

    say str('this. is, %a (test)'); # this is a test

=cut

sub strip_punctuation {
    my $self = shift;
    $self->{string} =~ s/[[:punct:]]//g;
    return $self;
}

=method swapcase

Swaps the case of the string.

    say str('TeSt')->swapcase->string; # tEsT

=cut

sub swapcase { shift->transliterate('a-zA-Z', 'A-Za-z'); }

=method concat($str1[, ...])

Concats multiple strings.
Aliases: C<suffix>

    say str('test')->concat('test')->string;            # testtest
    say str('test')->concat('test', 'test')->string;    # testtesttest

=cut

sub concat {
    my ($self, @strings) = @_;
    $self->{string} = $self->string . join '', @strings;
    return $self;
}

=method suffix($str1[, ...])

An alias to C<concat>.

=cut

sub suffix { shift->concat(@_); }

=method prefix($str1[, ...])

Prefix the string with C<$str1, ...>

    say str('test')->prefix('hello')->string;           # hellotest
    say str('test')->prefix('hello', 'world')->string;  # helloworldtest

=cut

sub prefix {
    my ($self, @strings) = @_;
    $self->{string} = join('', @strings) . $self->string;
    return $self;
}

=method reverse

Reverses a string.

    say str('test')->reverse->string; # tset

=cut

sub reverse {
    my $self = shift;
    $self->{string} = join '', reverse split //, $self->string;
    return $self;
}

=method count_words

Counts the words in a string.

    say str("this\tis a \t test")->count_words; # 4

=cut

sub count_words {
    my @arr = split /\s/, shift->clean->string;
    return $#arr + 1;
}

=method quote_meta

Quotes meta characters.

    # hello\ world\.\ \(can\ you\ hear\ me\?\)
    say str('hello world. (can you hear me?)')->quote_meta->string; 

=cut

sub quote_meta {
    my $self = shift;
    $self->{string} = quotemeta $self->string;
    return $self;
}

=method rot13

ROT13 transformation on the string.

    say str('this is a test')->rot13->string;           # guvf vf n grfg
    say str('this is a test')->rot13->rot13->string;    # this is a test

=cut

sub rot13 { shift->transliterate('A-Za-z', 'N-ZA-Mn-za-m'); }

=method say

Says the string.

    str('this is a test')->say; # displays "this is a test\n"

=cut

sub say { CORE::say shift->string; }

=method titleize

Strips punctuation and capitalizes each word.
Aliases: C<titlecase>

    say str('this is a test')->titleize->string; # This Is A Test

=cut

sub titleize {
    my $self = shift;
    $self->{string} = join ' ', map { str($_)->capitalize->string } 
                                    split / /, 
                                          $self->clean
                                               ->strip_punctuation
                                               ->string;
    return $self;
}

=method titlecase

An alias to C<titleize>.

=cut

sub titlecase { shift->titleize }

=method squeeze([$keep])

Deletes all consecutive same characters with exceptions.

    say str('woooaaaah, balls')->squeeze->string;         # woah, bals

    # keep consecutive 'a' characters
    say str('woooaaaah, balls')->squeeze->string;         # woaaaah, balls

    # keep characters from 'l' to 'o'
    say str('woooaaaah, balls')->squeze('l-o')->string;   # woooah, balls

=cut

sub squeeze {
    my ($self, $keep) = @_;
    $keep = '' unless defined $keep;
    $self->{string} =~ eval "\$self->{string} =~ tr/$keep//cs";
    return $self;
}

=method shuffle

Shuffles a string.

    say str('this is a test')->shuffle->string; # tsi  ssati the

=cut

sub shuffle {
    my $self = shift;
    $self->{string} = join '', List::Util::shuffle split //, $self->string;
    return $self;
}

=method transliterate

Transliterates a string into an another one. It wraps the C<tr()> Perl function.

    say str('test')->transliterate('a-z', 'A-Z')->string; # TEST

=cut

sub transliterate { 
    my ($self, $str1, $str2) = @_;
    $self->{string} =~ eval "\$self->{string} =~ tr/$str1/$str2/";
    return $self;
}

no Moo;

use base 'Exporter';

our @EXPORT = qw {
    str
};

=method str

Creates and returns a string object.

    str("test")->string                     # test
    str("test")->to_upper->string           # TEST
    str('this', 'is', 'a', 'test')->string; # this is a test

=cut

sub str {
    my $string = join ' ', @_;
    return Object::String->new(string => $string);
}

1;
