#Start

;building is yellow
@back building tint:yellow
@wait 0.2
@char Dani pos:51.5,51.7 scale:0.1,0.1


#Loop

get big on left, get small on right

	@char Dani tint:blue time:0.5 wait:false
	 @char Dani pos:60,40 scale:1.1,1.1 rotation:45 time:1.5 easing:Spring.EaseOut
		@wait 1.5
	@char Dani tint:red time:0.5 wait:false
	@char Dani pos:70,40 scale:0.9,0.9 rotation:-45 time:1 easing:Quad
	@wait 1
	@goto .Loop

#End
@stop
