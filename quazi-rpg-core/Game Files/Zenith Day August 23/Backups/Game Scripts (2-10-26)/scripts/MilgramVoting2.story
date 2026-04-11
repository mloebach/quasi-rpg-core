#MilgramVoting

[VOTING]

@goto .VotingStart if:episode>0
;@goto .VotingStart

...
{zenith_name}. Welcome back.
This is quick. While we can still talk to you, we will take a moment to guage your compatibility with these voyagers.
Which ones do you accept, and which ones do you reject?
From time to time, this is something you will be asked.
Answer honestly. The actors in this story will not hear you.
Whatever you answer will not bring harm to any of them, nor will it be able to help them.
You can vote according however you like. You can answer who you feel is the most like Zenith. You can answer who you are rooting for.
You can even answer to who you like, but who you don't like.
But the most important thing is to answer how you feel.
Let's go.


#VotingStart

@set current_vote="Quzeon"
@gosub .VoteLoop

@set current_vote="Yunyere"
@gosub .VoteLoop

@set current_vote="Ozapold"
@gosub .VoteLoop

@set current_vote="Deyacron"
@gosub .VoteLoop

@set current_vote="JQ3"
@gosub .VoteLoop

@set current_vote="Uelgwold"
@gosub .VoteLoop


@set current_vote="Veveya"
@gosub .VoteLoop

@set current_vote="Trophistus"
@gosub .VoteLoop

@set current_vote="Culpex"
@gosub .VoteLoop

@set current_vote="Ehrugarr"
@gosub .VoteLoop

@set current_vote="Liburri"
@gosub .VoteLoop

@set current_vote="Havi"
@gosub .VoteLoop

@set current_vote="Kennewick"
@gosub .VoteLoop

@set current_vote="Winckary"
@gosub .VoteLoop

@set current_vote="Regamirr"
@gosub .VoteLoop

;@save_variables

;Score: {score}
Thank you for your responses.

@return



#VoteLoop
;Response accepted.

@choice "Accept." set:Vote{int(episode)}{current_vote}="Accept";VoteResponse="ACCEPT" play:true
@choice "Reject." set:Vote{int(episode)}{current_vote}="Reject";VoteResponse="REJECT" play:true
@icon {current_vote}
@set score+=1
{current_vote}. Do you accept or reject?
;@icon {current_vote}
[center]{current_vote} - [b]{VoteResponse}[/b][/center]

@return
