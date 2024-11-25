# What is Recursion ?
People seem to think recursion means , my trigger ran twice, therefore it is recursive.
But that’s not true, recursion occurs when you are in the middle of one trigger transaction , and you called the same trigger again for some reason.
## Example :
A typical example might be a trigger on contacts that when you edit contact phone number it updates the account phone number . And you might have  another trigger on Account , when you update  the Account phone number it update the contact phone numbers.
So you can see in this potential situation , the contact could call the  Account could call the contact could call the Account and eventually you reach the recursion limit . _( stack depth LIMIT of 16)_
- This is Almost like an infinite loop.
- Recursion doesn’t have to be same trigger firing over and over again , it could be multiple triggers bouncing back and forth.

# How to Prevent Recursion ?

## Approach 1 :  [Use Static Boolean Variable]
The original idea was to use a static Boolean variable .
Usually it was in a function that you call run once  and if I have already ran then just go ahead and return early and that way we are not recursive.

## References
- [BadTriggerRecursionFix] class

## Why  this is not a best solution ?
If you make an API call and you set the "ALL" or "None" flag  to false .
Which means , you can have partial success .

In this case , what we may not realize is , that static variable isn't going to be reset in between the retries , that means ,
If you insert 200 records , and one of them errors and now only 199 are going to be in the second transaction ,but none of the code is going to run because you already ran once .so you miss out on that.

## Problems this approach have ?
    - Partial retry issue .
    - It messes up unit tests , if in our unit tests we are updating the same records again and again 
    - Breaks unit tests.
    - Breaks DML with more than 200 records.


## Approach 2 : [Use Static Set<Id> Variable] 
One other fix that people thought would be better is what if we only process the same records once .
In this case you might end up with Set<Id> .

    - With this notion, what we are doing here is we're saying if all the records have already been used ,then we don’t want to process those records again.

## References
- [BadTriggerRecursionFix] class

## Problems this approach have ?
    - Partial retry issue .
    - It messes up unit tests , if in our unit tests we are updating the same records again and again 
    - Breaks unit tests.

## Approach 3 : 
- This is like how salesforce does with flows , 
- Update  the record only if the old value is not equals to new value  .
- We check whether the Phone field has actually changed before performing updates. 
- This reduces unnecessary updates and avoids triggering the recursion unnecessarily.

## Approach 4 : [Using Loop Count Increment/decrement]

This way we go up one , when we done with these 200 records , we're gonna go back down one . 
We are in scenario where multiple DML's over each other  or next each other , then we enter the first batch of 200 records  - will count upto 1 .
Then we exit that DML operation will count back to 0 .

   - Now if we have the Contact.Phone → updating Account.Phone → updating Contact.Phone continues Scenario.
    - In this scenario , we will end up counting upwards , so we go one , two, three four until we hit our max limit of recursion(16), that we want and then will die. 
    - So just be not holding on to that any longer than necessary ,we can fix the problem of counting up infinitely .

## References
- [RecursionManager,ContactTriggerHandler] class

 
## Example of Recursion Breakdown:
Let’s assume you're starting with a Contact update and it leads to the following:
   - 1. Cycle 1:
        ○ Contact update triggers Account update → Recursion count = 1
        ○ Account update triggers Contact update → Recursion count = 2
   - 2. Cycle 2:
        ○ Contact update triggers Account update → Recursion count = 3
        ○ Account update triggers Contact update → Recursion count = 4
   - 3. Cycle 3:
        ○ Contact update triggers Account update → Recursion count = 5
        ○ Account update triggers Contact update → Recursion count = 6(This continues until the recursion count reaches 16)
    - 4. Cycle 8:
        ○ Contact update triggers Account update → Recursion count = 15
        ○ Account update triggers Contact update → Recursion count = 16 (maximum reached, exit).

## Conclusion:
- In this specific case, the recursion happens a total of 16 times, which means there will be 8 complete cycles  (each cycle consisting of a Contact update and an Account update). 
- After the recursion count reaches the maximum limit of 16, the trigger will stop executing, preventing infinite recursion and ensuring the system behaves as expected.
- If you want to make sure that the recursion doesn't get out of hand in your system, it's crucial to set the _(MAX_RECURSION_DEPTH)_ to a reasonable limit and to track the recursion depth using a static variable as we've done in this example.

