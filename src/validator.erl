-module( validator ).
-author( "Warren Kenny <warren.kenny@gmail.com>" ).

-export( [ validate/2 ] ).

%%
%%	Specification Type
%%
-type spec() :: atom() | { atom(), integer() } | { atom(), integer(), integer() }.

%%
%%	Match the given value against the provided list of specifications. If
%%	any of the specifications fail, all failed steps will be returned in
%%	a list along with the value. Otherwise, the failure list will be empty
%%
%% Specifications:
%%
%%	required				- Indicates that the value must be present. Fails if the value is matches the atom 'undefined'
%% 	boolean					- Value must be a boolean or a string that can be converted cleanly to a boolean
%%	integer					- Value must be an integer
%%	numeric					- Value must be an integer or floating-point value
%%	{ length, Len }			- String value must be Len characters long
%%	{ length, Min, Max }	- String value must be between Min and Max characters long
%% 	{ whitelist, [char] }	- String value can only contain characters in the given whitelist
%%	{ blacklist, [char] }	- String value cannot contain characters in the given blacklist
%%	{ bounded, Min, Max }	- Numeric value must be greater than or equal to Min and less than or equal to Max
%%	{ min, Min }			- Numeric value must be greater than or equal to Min
%%	{ max, Max }			- Numeric value must be less than or equal to Max
%%
%% Parameters:
%%	Value 	- The value to be matched against the spec
%%	Spec	- List of validation specifications
%%
%% Returns:
%%	{ ok, Value }				- On Success
%% 	{ error, Value, Errors }	- On Failure
%%
-spec validate( term(), [ spec() ] ) -> { ok, term() } | { error, term(), [ binary() ] }.
validate( Value, Spec ) when is_list( Spec ) ->
	validate( Value, Spec, [] );

validate( Value, Spec ) ->
	validate( Value, [Spec], [] ).

%%
%%	Check whether the value has been defined. If the check fails, return immediately since all other
%%	validations would fail anyway.
%%
-spec validate( term(), [ spec() ], [binary()] ) -> { ok, term() } | { erro, term(), [ binary() ] }.
validate( undefined, [ required | _Rest ], Errors ) ->
	{ error, undefined, [ <<"Value is undefined">> | Errors ] };

validate( Value, [ required | Rest ], Errors ) ->
	validate( Value, Rest, Errors );

%%
%%	Check whether the value is a string
%%
validate( Value, [ string | Rest ], Errors ) when is_list( Value ); is_binary( Value ) ->
	validate( Value, Rest, Errors );

validate( Value, [ string | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value is not a string">> | Errors ] );

%%
%%	Check whether the value is an integer
%%
validate( Value, [ integer | Rest ], Errors ) when is_integer( Value ) ->
	validate( Value, Rest, Errors );

validate( Value, [ integer | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value is not an integer">> | Errors ] );

%%
%%	Check whether the value is a boolean. If the value is a string that can be 
%%	interpreted as a boolean, this function will make the conversion before
%%	continuing with validation.
%%
validate( Value, [ boolean | Rest ], Errors ) when is_boolean( Value ) ->
	validate( Value, Rest, Errors );

validate( <<"true">>, [ boolean | Rest ], Errors ) ->
	validate( true, Rest, Errors );
validate( "true", [ boolean | Rest ], Errors ) ->
	validate( true, Rest, Errors );

validate( <<"false">>, [ boolean | Rest ], Errors ) ->
	validate( false, Rest, Errors );
validate( "false", [ boolean | Rest ], Errors ) ->
	validate( false, Rest, Errors );

validate( Value, [ boolean | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value is not a boolean">> | Errors ] );

%%
%%	Check whether the value is numeric ( integer or floating-point )
%%
validate( Value, [ numeric | Rest ], Errors ) when is_integer( Value ); is_float( Value ) ->
	validate( Value, Rest, Errors );

validate( Value, [ numeric | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value is not numeric">> | Errors ] );


%%
%%	Check whether the value's length is equal to Len
%%
validate( Value, [ { length, Len } | Rest ], Errors ) when byte_size( Value ) == Len ->
	validate( Value, Rest, Errors );

validate( Value, [ { length, Len } | Rest ], Errors ) when length( Value ) == Len ->
	validate( Value, Rest, Errors );

validate( Value, [ { length, _Len } | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value has incorrect length">> | Errors ] );

%%
%%	Character black and white listing
%%
validate( Value, [{ whitelist, Chars } | Rest], Errors ) when is_list( Value ) ->
	case lists:all( fun( C ) -> lists:member( C, Chars ) end, Value ) of
		true 	-> validate( Value, Rest, Errors );
		false 	-> validate( Value, Rest, [ <<"Value contains non-whitelisted characters">> | Errors ] )
	end;

validate( Value, [{ blacklist, Chars } | Rest], Errors ) when is_list( Value ) ->
	case lists:all( fun( C ) -> lists:member( C, Chars ) =:= false end, Value ) of
		true 	-> validate( Value, Rest, Errors );
		false 	-> validate( Value, Rest, [ <<"Value contains non-whitelisted characters">> | Errors ] )
	end;

%%
%%	Check whether the value's length is greater than Min and less than or equal to Max
%%
validate( Value, [ { length, Min, Max } | Rest ], Errors ) when byte_size( Value ) >= Min, byte_size( Value ) =< Max ->
	validate( Value, Rest, Errors );

validate( Value, [ { length, Min, Max } | Rest ], Errors ) when length( Value ) >= Min, length( Value ) =< Max ->
	validate( Value, Rest, Errors );

validate( Value, [ { length, _Min, _Max } | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value has incorrect length">> | Errors ] );

%%
%%	Check whether the value is greater or equal to Min and less than or equal to Max
%%
validate( Value, [ { bounded, Min, Max } | Rest ], Errors ) when Value >= Min, Value =< Max ->
	validate( Value, Rest, Errors );

validate( Value, [ { bounded, _Min, _Max } | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value has incorrect magnitude">> | Errors ] );

%%
%%	Check whether the value is greater or equal to Min
%%
validate( Value, [ { min, Min } | Rest ], Errors ) when Value >= Min ->
	validate( Value, Rest, Errors );

validate( Value, [ { min, _Min } | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value has incorrect magnitude">> | Errors ] );

%%
%%	Check whether the value is less than or equal to Max
%%
validate( Value, [ { max, Max } | Rest ], Errors ) when Value =< Max ->
	validate( Value, Rest, Errors );

validate( Value, [ { max, _Max } | Rest ], Errors ) ->
	validate( Value, Rest, [ <<"Value has incorrect magnitude">> | Errors ] );

%%
%%	Return the result
%%
validate( Value, [], [] ) ->
	{ ok, Value };

validate( Value, [], Errors ) ->
	{ error, Value, Errors }.