-module(kitchen).
-compile(nowarn_export_all).
-compile(export_all).

% no state, calls function from scratch each time
fridge1() ->
    receive
        {From, {store, _Food}} ->
            From ! {self(), ok},
            fridge1();
        {From, {take, _Food}} ->
            From ! {self(), not_found},
            fridge1();
        terminate ->
            ok
    end.

% adding state via recursion
fridge2(FoodList) ->
    receive
        {From, {store, Food}} ->
            From ! {self(), ok},
            fridge2([Food | FoodList]);
        {From, {take, Food}} ->
            case lists:member(Food, FoodList) of
                true ->
                    From ! {self(), {ok, Food}},
                    fridge2(lists:delete(Food, FoodList));
                false ->
                    From ! {self(), not_found},
                    fridge2(FoodList)
            end;
        terminate ->
            ok
    end.

% The store/2 function takes two arguments: Pid (process identifier) and Food (the food item to be stored). It performs the following steps:

% Sends a message to the process identified by Pid using the ! operator. The message is a tuple containing the current process identifier (self()) and a tuple {store, Food} representing the action of storing the food item.
% Waits to receive a response through the receive block.
% Matches the received message against the pattern {Pid, Msg} and returns Msg.

store(Pid, Food) ->
    Pid ! {self(), {store, Food}},
    receive
        {Pid, Msg} -> Msg
    end.

take(Pid, Food) ->
    Pid ! {self(), {take, Food}},
    receive
        {Pid, Msg} -> Msg
    end.

% One thing left to do would be to hide that whole part about needing to spawn a process. We dealt with hiding messages, but then we still expect the user to handle the creation of the process. I'll add the following start/1 function:
% ?MODULE is a macro returning current module's name

start(FoodList) ->
    spawn(?MODULE, fridge2, [FoodList]).

store2(Pid, Food) ->
    Pid ! {self(), {store, Food}},
    receive
        {Pid, Msg} -> Msg
    after 3000 ->
        timeout
    end.

take2(Pid, Food) ->
    Pid ! {self(), {take, Food}},
    receive
        {Pid, Msg} -> Msg
    after 3000 ->
        timeout
    end.
