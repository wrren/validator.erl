
-module( validator_tests ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-include_lib( "eunit/include/eunit.hrl" ).

basic_test() ->
    { ok, 1 }			= validator:validate( 1, 			[] ).

integer_test() ->
	{ ok, 1 }			= validator:validate( 1, 			[ integer ] ),
	{ ok, 1 }			= validator:validate( 1,			[ integer, { min, 1 } ] ).
	
numeric_test() ->
	{ ok, 1 }			= validator:validate( 1, 			[ numeric ] ),
	{ ok, 1.0 }			= validator:validate( 1.0, 			[ numeric ] ).
	
boolean_test() ->
	{ ok, true }		= validator:validate( true, 		[ boolean ] ),
	{ ok, false }		= validator:validate( false, 		[ boolean ] ),
	{ ok, true }		= validator:validate( "true", 		[ boolean ] ),
	{ ok, true }		= validator:validate( <<"true">>, 	[ boolean ] ),
	{ error, _, _ }		= validator:validate( <<"yes">>, 	[ boolean ] ),
	{ ok, false }		= validator:validate( "false", 		[ boolean ] ),
	{ ok, false }		= validator:validate( <<"false">>, 	[ boolean ] ).
	
string_test() ->
	{ ok, "Hello" }		= validator:validate( "Hello",		[ string, { length, 5 } ] ),
	{ ok, <<"Hello">> }	= validator:validate( <<"Hello">>,	[ string, { length, 5 } ] ),
	
	{ ok, "Hello" }		= validator:validate( "Hello",		[ string, { whitelist, ["olleH", alpha] } ] ),
	{ ok, <<"Hello">> }	= validator:validate( <<"Hello">>,	[ string, { whitelist, ["olleH", alpha] } ] ),
	{ ok, "Hello" }		= validator:validate( "Hello",		[ string, { whitelist, [alphanumeric] } ] ),
	{ ok, "12345" }		= validator:validate( "12345",		[ string, { whitelist, [alphanumeric] } ] ),
	{ error, _, _ }		= validator:validate( "Hello",		[ string, { whitelist, ["ello"] } ] ),
	{ error, _, _ }		= validator:validate( "Hello",		[ string, { whitelist, [numeric] } ] ),
	
	{ ok, <<"Hello">> }	= validator:validate( <<"Hello">>,	[ string, { blacklist, [numeric] } ] ),
	{ error, _, _ }		= validator:validate( "Hello",		[ string, { blacklist, [alpha] } ] ),
	{ ok, "Hello" }		= validator:validate( "Hello",		[ string, { blacklist, ["zx!654"] } ] ),
	{ error, _, _ }		= validator:validate( "Hello",		[ string, { blacklist, ["l"] } ] ),

	{ error, 1, _ }		= validator:validate( 1,			[ string ] ).