## Validator

Simple input validation module for erlang applications. Allows variables to be tested
against a list of validation specifications.

## Specifications

Specifications are passed as a list of atoms and/or key/value tuples to the validate function.

```erlang

required				%% Indicates that the value must be present. Fails if the value is matches the atom 'undefined'
boolean					%% Value must be a boolean or a string that can be converted cleanly to a boolean
integer					%% Value must be an integer
numeric					%% Value must be an integer or floating-point value
{ length, Len }			%% String value must be Len characters long
{ length, Min, Max }	%% String value must be between Min and Max characters long
{ bounded, Min, Max }	%% Numeric value must be greater than or equal to Min and less than or equal to Max
{ min, Min }			%% Numeric value must be greater than or equal to Min
{ max, Max }			%% Numeric value must be less than or equal to Max

```

## Examples

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