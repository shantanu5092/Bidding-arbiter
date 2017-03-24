# Bidding-arbiter
Designed a bidding arbiter for granting bus access to the selected master
The arbiter will handle 4 masters and 4 slaves. The account for each master shall be limited to 1. Initially, every master has an account balance of 900. Some of the features of this arbiter are:
1.	Some of the values that come from test-bench are amount to add to the account each interval, number of clocks per interval, and the maximum account balance.
2.	If the bid is made larger than the account balance, then the account balance is substituted for the bid. 
3.	Master’s with equal winning bids are handled on a last won lowest priority scheme.
4.	If a master is continously bidding and has not been served for past 60 clocks, then it must be served.
5.	Master who bids a bigger amount wins.
6.	After every 400 clock cycles, account balance is refilled with 750.
