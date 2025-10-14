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
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Quzeon. Do you accept or reject?

@set current_vote="Yunyere"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Yunyere. Do you accept or reject?

@set current_vote="Ozapold"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Ozapold. Do you accept or reject?

@set current_vote="Deyacron"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Deyacron. Do you accept or reject?

@set current_vote="JQ3"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
JQ3. Do you accept or reject?

@set current_vote="Uelgwold"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Uelgwold. Do you accept or reject?


@set current_vote="Veveya"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Veveya. Do you accept or reject?


@set current_vote="Trophistus"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Trophistus. Do you accept or reject?

@set current_vote="Culpex"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Culpex. Do you accept or reject?

@set current_vote="Ehrugarr"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Ehrugarr. Do you accept or reject?

@set current_vote="Liburri"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Liburri. Do you accept or reject?

@set current_vote="Havi"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Havi. Do you accept or reject?

@set current_vote="Kennewick"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Kennewick. Do you accept or reject?

@set current_vote="Winckary"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Winckary. Do you accept or reject?

@set current_vote="Regamirr"
@choice "Accept." set:Vote{episode}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{episode}{current_vote}="Reject" play:true
@icon {current_vote}
Regamirr. Do you accept or reject?

@save_variables
@return




#VoteChoices
;Response accepted.
@choice "Accept." set:Vote{int(episode)}{current_vote}="Accept" play:true
@choice "Reject." set:Vote{int(episode)}{current_vote}="Reject" play:true


@return
