

First Line
@set score=10
@set name="Matt"

@group
	TestA
	@if score<5
		TestB
		TestB2
		TestB3
	@else score>4
		Test4
	TestC

@random weight:0.1,1.0
	@group
		You didn't get it this time.
	@group
		@if score<5
			@if name="Sam"
				C'mon. You can do better than that!
			@else if:name="Matt"
				Good job!
			@else
				Meh.
		@else if:score>12
			Pretty good!
		@else
			Just average.
			You can do better.

And we're good!
@stop
