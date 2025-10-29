@choice "Skip" play:true
@set score=30
@cg WhiteScreen
;@icon Uelgwold
Ehrugarr: {test_func("2")} Pilgrimage to {z_pro("their")} {z_pro("Them")} {z_pro("THEMSELF")} Zenith: {int(score)}

Ehrugarr: {test_func("2")} Pilgrimage to {z_pro("their")} {z_pro("Them")} {z_pro("THEMSELF")} Zenith: {int(score)}
Ehrugarr: {test_func("2")} Pilgrimage to {z_pro("their")} {z_pro("Them")} {z_pro("THEMSELF")} Zenith: {int(score)}

@openURL "https://godotengine.org"

@status Quzeon.Eliminated
@status Culpex.Eliminated
@status Regamirr.Eliminated
@status JQ3.Eliminated
@status Ehrugarr.Eliminated

...

;@choice "When we were apart, it was a different story!" play:true
;@choice "Skip this part"
;	@icon Quzeon
;	But I love this show!


@set score=4
@set big_bag=true
@set with_one_cookie=false
@cg Gunshot
Score {score}
@set episode={score}
@set nextscript="Voting"
;@goto {nextscript}
@gosub {nextscript}


#AfterChoice
;@choice "Secret Choice" show:false
Uh Oh...
@gosub .ChoiceLoop
Go Sub loop 1 exited.
@goto .Questions
@stop

#ChoiceLoop
Go sub loop entered.
Sentence one.
@gosub .ChoiceLoop2
Loop2 Exited
@return

#ChoiceLoop2
Go sub loop 2 entered
Sentence two.
Sentence 3.
@return



#Questions
;Question.

@set score+=1


;@choice "My mother ate fries!" lock:big_bag time:4
;	You picked fry option.
;	@goto .AfterChoice
@choice "Tonya ate slices!" goto:.AfterChoice lock:score<1 set:big_bag=false;with_one_cookie=true;penis=true;score=6 time:4 play:true
	
@choice "Drew ate donuts!" lock:1==2 time:5 play:false
;@choice "...and I ate it all!" lock:score>=5 time:1
;	Unfortunately...
;	They were still talking about cookies.

When we were apart, it was a different story!

The only one who stuck to the diet...


#AfterChoices

@cg VSDarkHusk15
.
@cg OzapoldShock
.
@cg TrophistusStab
.
@cg EhrugarrEliminated
