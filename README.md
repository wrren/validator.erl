## Validator

Simple input validation module for erlang applications. Allows variables to be tested
against a list of validation specifications.

## Specifications

Specifications are passed as a list of atoms and/or key/value tuples to the validate function.

```erlang

%% Test for non-undefined variable
{ error, _, _ }		= validator:validator( undefined, 	[ required ] ),

%% Empty spec, always succeeds
{ ok, 1 }			= validator:validate( 1, 			[] ),

%% Test for integer type with constraints
{ ok, 1 }			= validator:validate( 1, 			[ integer ] ),
{ ok, 1 }			= validator:validate( 1,			[ integer, { min, 1 } ] ),
	
%% Tests for any numeric type
{ ok, 1 }			= validator:validate( 1, 			[ numeric ] ),
{ ok, 1.0 }			= validator:validate( 1.0, 			[ numeric ] ).
	
%% Tests for and converts boolean inputs. Will convert strings representing boolean
%% values into boolean atoms.
{ ok, true }		= validator:validate( true, 		[ boolean ] ),
{ ok, false }		= validator:validate( false, 		[ boolean ] ),
{ ok, true }		= validator:validate( "true", 		[ boolean ] ),
{ ok, true }		= validator:validate( <<"true">>, 	[ boolean ] ),
{ error, _, _ }		= validator:validate( <<"yes">>, 	[ boolean ] ),
{ ok, false }		= validator:validate( "false", 		[ boolean ] ),
{ ok, false }		= validator:validate( <<"false">>, 	[ boolean ] ).
	
%% String type with constraints. Works with both strings and binaries 
{ ok, "Hello" }		= validator:validate( "Hello",		[ string, { length, 5 } ] ),
{ ok, <<"Hello">> }	= validator:validate( <<"Hello">>,	[ string, { length, 5 } ] ),
{ error, 1, _ }		= validator:validate( 1,			[ string ] ).

```