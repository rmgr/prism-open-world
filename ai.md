# Kobold Behaviour Tree
```
Check if we have a long term goal in mind
    Yes
    Set goal to target
    Move
Check if enemy is visible
    Yes
    Check if HP <= 33%
        Yes
        Find a nearby room and set it as a long term goal
        Move

        No 
        Check if enemy is in combat range
            Yes
            Attack
            
            No
            Move
    No
    Wait
```

