package Acme::Voodoo;

use strict;
use warnings;
use base qw( Exporter );
use Carp qw( croak );

our @EXPORT = qw( voodoo_doll voodoo_pins voodoo_zombie voodoo_kill );
our $VERSION = 0.1;

my %dolls = ();
my %dead = ();
my %zombie = ();

=head1 NAME

Acme::Voodoo - Do bad stuff to your objects 

=head1 SYNOPSIS

    use Acme::Voodoo;
    my $voodoo = Acme::Voodoo( 'CGI' );
    
    print ref( $voodoo );	## prints Acme::Voodoo::Doll_1
    print $voodoo->header();	## same as calling CGI::header()

    @pins = $voodoo->pins();	## get a list of methods you can call

    $voodoo->zombie();		## make our program sleep for a while
				## the next time a method is called

    $voodoo->kill();		## or make our program die the next time it is 
				## called 

=head1 ABSTRACT

Voodoo is an Afro-Caribbean religion that mixed practices from the Fon, 
the Nago, the Ibos, Dahomeans, Congos, Senegalese, Haussars, Caplauous, 
Mondungues, Madinge, Angolese, Libyans, Ethiopians and the Malgaches.
With a bit of Roman Catholicism thrown in for good measure. This melange was
brought about by the enforced immigration of African slaves into Haiti during
the period of European colonizaltion of Hispaniola.  The colonists thought that a divided group of different tribes would be easier to enslave; but little 
did they know that the tribes had a common thread. 

In reality the actual religion is called "Vodun", while "Voodoo" is a largely
imaginary religion created by Hollywood movies. Vodun priests can be male
(houngan) and female (mambo) and confine their activites to "white" magic. 
However caplatas (also known as bokors) do practice acts of evil sorcery, 
which is sometimes referred to "left-handed Vodun".

Acme::Voodoo is mostly "left handed" and somewhat "Hollywood-ish" but can 
bring a bit of spice to your programs. You can cast fairly simple spells on 
your program to make it hard to understand, or to make it die a horrible 
death. If you would like to add a spell please email me a patch. Or send it
via astral-projection. Acme::Voodoo is essentially an experiment in symbol table
gone horribly wrong.

=head1 EXPORTS

=head2 new()

Creates a voodoo doll object. You must pass the namespace of your subject. If 
your subject isn't within spell distance (the class can't be found) an 
exception will be thrown. Otherwise you get back your doll, a Acme::VoodooDoll 
object.

    use Acme::Voodoo;
    my $doll = Acme::Voodoo->new( 'CGI' );
    print $doll->header();

=cut

sub new {

    ## uhoh, voodoo 
    no strict;

    ## figure out what class we are targeting
    my ( $voodooClass, $targetClass, @args ) = @_; 
    eval "use $targetClass";
    croak "I can't find $targetClass to put a spell on" if !$targetClass or $@; 

    ## if the class doesn't have a new constructor we can't cast our spell 
    return( undef ) if ! exists( ${ "${targetClass}::" }{ 'new' } );

    ## determine a new namespace for our voodoo doll
    my $dollNum = scalar( keys( %dolls ) );
    my $dollClass = "Acme::Voodoo::Doll_$dollNum";

    ## go through our target namespace and copy non subroutines
    while  ( ($k,$v) = each %{ "${targetClass}::" } ) {
	
	## add non subroutines to our voodoo doll namespace
	if ( !defined(&{$v}) ) { ${ "${dollClass}::" }{ $k } = $v; }

    }

    ## create an instance of our target class, and stash it away
    my $instance = &{ "${targetClass}::new" }( @args );
    $dolls{ $dollClass } = $instance;

    ## create the appropriate type of reference
    my $ref;
    if ( $instance =~ /HASH/ ) { $ref = {}; }
    elsif ( $instance =~ /ARRAY/ ) { $ref = []; }
    elsif ( $instance =~ /GLOB/ ) { 
	croak "glob objects are currently resistant to our voodoo spells!"; 
    }
    $doll = bless $ref, $dollClass;

    ## make our voodoo doll namespace inherit the AUTLOADER
    ## from the Acme::Voodoo namespace so we can trap method calls
    push( @{ "${dollClass}::ISA" }, 'Acme::Voodoo' );

    return( $doll );

}

=head2 pins()

Pass this function your voodoo doll and you'll get back a list of pins you 
can use on your doll.

    my @pins = $doll->pins();

=cut 

sub pins {
    my $doll = shift;
    my $dollClass = ref( $dolls{ ref($doll) } );
    my @methods = ();
    return( () ) if !$dollClass;

    no strict;
    while ( my($k,$v) = each( %{ "${dollClass}::" } ) ) {
	push( @methods, $k ) if defined &{ $v };
    }

    return( @methods );
}

=head2 zombie()

A method to turn your object into a zombie. The next method call on the object
will cause your program to go to sleep for into limbo for an unpredictable
amount of time. When it wakes up, it will do what you asked it to do, and will
feel fine from then on, having no memory of what happened.

=cut 

sub zombie {
    my $self = shift;
    $zombie{ ref($self) } = 1;
    return(1);
}

=head2 kill()

When you kill your doll, the next time someone calls a method on it it will 
cause your program to die a horrible and painful death.

    $doll->kill();
    $doll->method();	    ## cause die to be thrown.

=cut

sub kill {
    my $self = shift;
    $dead{ ref($self) } = 1;
    return( 1 );
}

=head1 AUTHOR

Ed Summers, E<lt>ehs@pobox.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002 by Ed Summers

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. Just be sure not to use it for
anything important.

=cut

sub AUTOLOAD { 

    my ($doll,@args) = @_;
    our $AUTOLOAD;

    ## if we're dead, then we're gonna die
    croak( "arrrghgghg, an evil curse has struck me down!\n" )
	if $dead{ ref($doll) };

    ## if we are a zombie, go to sleep for a random amount of time
    ## and then wake up remembering nothing
    if ( $zombie{ ref($doll) } ) {
	print STDERR "i feel as if I'm walking into a strange dream\n";
	sleep( int( rand(100) ) );
	$zombie{ ref($doll) } = undef;
    }

    ## strip namespace off of method
    my ($method) = ( $AUTOLOAD =~ /.*::(.*)$/ );

    ## our real object
    my $object = $dolls{ ref($doll) };
    my $class = ref( $object );
    
    no strict;
    return( undef ) if $method eq 'DESTROY';
    &{ "${class}::${method}" }( $object, @args );

}


1;
