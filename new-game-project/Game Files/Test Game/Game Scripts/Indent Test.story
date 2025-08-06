

First Line
@set score=10
@set name="Matt"

@random
	@group
		You didn't get it this time.
	@group
		@if score < 5
			@if name="Sam":
				C'mon. You can do better than that!
			@else if:name="Matt":
				Good job!
		@else if:score>12:
			Pretty good!
		@else
			Just average.
			You can do better.
@stop
