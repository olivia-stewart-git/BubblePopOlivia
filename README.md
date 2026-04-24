# Assignment 2


For structuring the project I tried to adhere to an mvc structure.

I used interface segregation with some services to try keep complex logic 
away from the views where possible.

Styling is quite simple.


GameModelView is structured in a way with dependency injection, this is to support
the possiblity of extension in the future aswell as unit-testability.
