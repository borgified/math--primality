package Math::Primality::AKS;
use warnings;
use strict;

use Math::GMPz qw/:mpz/;
use base 'Exporter';
use Carp qw/croak/;

use constant DEBUG => 0;

use constant GMP => 'Math::GMPz';

=head1 NAME

Math::Primality::AKS - The Agrawal-Kayal-Saxena primality testing algorithm

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
$VERSION = eval $VERSION;

our @EXPORT_OK = qw/is_aks_prime/;

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

=head1 SYNOPSIS

    use Math::Primality::AKS;

    my $n = 123;
    print 'Prime!' if is_aks_prime($n);

=head1 DESCRIPTION

=head1 EXPORT

=head1 FUNCTIONS

=head2 aks($n)

=cut

sub debug {
    if ( DEBUG or $ENV{DEBUG} ) {
      warn $_[0];
    }
}

sub is_aks_prime($) {
  # http://ece.gmu.edu/courses/ECE746/project/F06_Project_resources/Salembier_Southerington_AKS.pdf
  # http://islab.oregonstate.edu/koc/ece575/04Project2/Halim-Chanleudfa/Report.pdf
  # http://fatphil.org/maths/AKS/
  my $n = GMP->new($_[0]);
  # Step 1 - check if $n = m^d for some m, d
  # if $n is a power then return 0
  if (Rmpz_perfect_power_p($n)) {
    debug "fails step 1 of aks - $n is a perfect power";
    return 0;  # composite
  }
    my $r = Math::GMPz->new(2);
    my $logn = Rmpz_sizeinbase($n, 2);
    my $limit = Math::GMPz->new($logn * $logn);
    Rmpz_mul_ui($limit, $limit, 4);

    # Witness search

    OUTERLOOP: while (Rmpz_cmp($r, $n) == -1) {
    if(Rmpz_divisible_p($n, $r)) {
        debug "$n is divisible by $r\n";
        return 0;
    }

    if(Rmpz_probab_prime_p($n, 5)) {
        my $i = Math::GMPz->new(1);

        INNERLOOP: for ( ; Rmpz_cmp($n, $limit) <= 0; Rmpz_add_ui($i, $i, 1)) {
        my $res = Math::GMPz->new(0);
        Rmpz_powm($res, $n, $i, $r);
        if (Rmpz_cmp_ui($res, 1) == 0) {
            last OUTERLOOP;
        }
        }

    }
    Rmpz_add_ui($r, $r, 1);
    }
    if (Rmpz_cmp($r, $n) == 0) {
        debug "Found $n is prime while checking for r\n";
        return 1;
    }

    # Polynomial check
    my $a;
    my $sqrtr = Math::GMPz->new(0);

    Rmpz_sqrt($sqrtr, $r);
    my $polylimit = Math::GMPz->new(0);
    Rmpz_add_ui($polylimit, $sqrtr, 1);
    Rmpz_mul_ui($polylimit, $polylimit, $logn);
    Rmpz_mul_ui($polylimit, $polylimit, 2);

    my $intr = Rmpz_get_ui($r);

    for($a = 1; Rmpz_cmp_ui($polylimit, $a) <= 0; $a++) {
        debug "Checking at $a\n";
        my $final_size = Math::GMPz->new(0);
        Rmpz_mod($final_size, $n, $r);
        my $compare = polynomial->new(Rmpz_get_ui($final_size));
        $compare->setCoef(1, Rmpz_get_ui($final_size));
        $compare->setCoef($a, 0);
        my $res = polynomial->new($intr);
        my $base = polynomial->new(1);
        $base->setCoef($a, 0);
        $base->setCoef(1, 1);

        mpz_poly_mod_power($res, $base, $n, $n, $intr);

        if($res->isEqual($compare)) {
            debug "Found not prime at $a\n";
            return 0;
        }
    }
    return 1;
}

=head1 AUTHORS

Bob Kuo, C<< <bobjkuo at gmail.com> >>
Jonathan "Duke" Leto C<< <jonathan@leto.net> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-math-primality-aks at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Math::Primality::AKS>.  I will be 
notified, and then you'll automatically be notified of progress on your bug as I
make changes.

=head1 THANKS

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Math::Primality::AKS


You can also look for information at:

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2009-2010 Bob Kuo, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

exp(0); # End of Math::Primality::AKS
