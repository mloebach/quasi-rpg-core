Message 1

@set score=1

Message 2. Score is {score}.

@choice Skip to Gosub gosub:.loop

@set score+=4

Message 3. Now score is {score}.

Entering pocket dimension.

@gosub .loop
...
@gosub .loop
...
@gosub .loop

Exiting loop.

Score is now {score}.
@stop

#loop

@set score+=1
Inside pocket dimension. Score is now {score}.
@return

#loop2
You're stuck here forever!
;@stop
