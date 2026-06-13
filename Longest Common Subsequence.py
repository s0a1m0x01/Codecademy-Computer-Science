Skip to Content

Dynamic Programming

Ask the AI Learning Assistant
Get Unstuck
Tools

Avatar
Longest Common Subsequence
Project Brief
Objective
Intro to Programming
Longest Common Subsequence
Given two strings: "ABAZDC" and "BACBAD", how can we determine the longest common subsequence?

In other words, what series of letters from left to right do they share? The letters don’t need to be directly next to each other. In this example, the longest sequence is "ABAD" for a length of 4.

Longest Common Subsequence may seem like an obscure problem, but it has applications in genomics. “A”, “C”, “G”, and “T” represent the four nucleotide bases of a DNA strand. The longest common subsequence of among these letters would provide valuable information about two people’s genetics.

A naive approach would be to generate every subsequence of each string. We then check the longest generated subsequence of each string to see if they match, checking smaller and smaller subsequences if they don’t. This approach has a big O runtime of O(2^N).

Let’s apply what we’ve learned about Dynamic Programming to produce a more efficient solution!

Tasks
10/10 complete
Mark the tasks as complete by checking them off
Setting up the Problem
1.
We’ll need some inputs for our problem.

Declare dna_1 and set it to "ACCGTT".

Declare dna_2 and set it to "CCAGCA".

2.
Below our test variables, define the longest_common_subsequence() function, which has two parameters: string_1 and string_2.

Inside the function add this line:

print("Finding longest common subsequence of {0} and {1}".format(string_1, string_2))

Copy to Clipboard

Creating a Grid
3.
Similar to the knapsack problem, we’re going to create a grid that will store our sub-answers.

For the longest common subsequence, we’ll need a grid where the columns are each character from one string, and the rows are each character from the other string. We’ll add an extra column and row to represent an empty string or “no character”.

Declare the variable grid and set it to two list comprehensions, one nested inside the other.

The inner list comprehension will place a 0 for each character plus one in string_1.

The outer list comprehension will run the inner list comprehension for each character plus one in string_2.

4.
With a grid in place, let’s iterate through each cell.

Our approach will be to compare each letter from one string with each letter from the other.

We’ll do this comparison by nested for loops.

After initializing grid, loop for row in range(1, len(string_2) + 1):

Inside this loop, add the statement:
print("Comparing: {0}".format(string_2[row - 1]))

5.
Inside this first loop, add another for loop to compare each of the “column” characters:

for col in range(1, len(string_1) + 1):

Inside this loop, add another print statement:

print("Against: {0}".format(string_1[col - 1]))

6.
If you haven’t already, run the code and see how the comparisons progress.

Given "ACCGTT" and "CCAGCA", we’re pretending we have just a string of "A".

Then we ask “What would be the longest common subsequence if this matched "C", then "C", then "A", etc.? It would be 1 plus whatever we had without this match. If it didn’t match, it would be whatever we had without the match.

“Without this match” is an earlier cell in our grid, a cell which does not contain the current letters we’re comparing. To start, that cell is our “no character” row and/or column.

See how this is using sub-problems to build up our final answer? If we know the answer to a string of length 1, it’s only one more letter to check for a string of length 2, and so on.

Hopefully, this helps make our strategy more concrete.

In the next section, we’ll fill in the grid to find our answer!

Filling the Grid
7.
Inside the inner loop, after print("Against: {0}".format(string_1[col - 1])), compare string_1[col - 1] == string_2[row - 1]:

If these letters match, we have a subsequence of at least 1.

We say “at least” because maybe there have been previous matches. Those matches live in the cell of our grid that excludes our current characters: grid[row - 1][col - 1].

Putting this together, we set grid[row][col] to be the value at grid[row - 1][col - 1] plus 1 for the current match.

8.
Now let’s cover what happens with the characters do not match. Make an else block for our conditional.

Inside the block, we need to set a value for grid[row][col].

This value will be the best we’ve seen excluding either character. In other words, the values located at the prior row or column.

We can use max() to return the higher value from grid[row - 1][col] and grid[row][col - 1].

9.
That’s all the work we need to do to populate the grid! Our runtime improved dramatically to O(M * N), where M and N are the lengths of the two strings.

Once both loops conclude, the length of the longest common subsequence is located at grid[-1][-1].

You can enter this code at the bottom of the function to see the entire grid:

for row_line in grid:
  print(row_line)

Copy to Clipboard

Extra Credit: The Subsequence
10.
Our function returns the length of the longest subsequence, but not the subsequence itself.

If we care about that value, we have a bit more work to do.

We’ll detail the approach, see if you can code out a solution.

Start from the bottom right cell of the grid. If the indices of each string are matching characters, add that character to the result and decrement each index.

Remember, the index for string_1 was col and the index for string_2 was row.

If they don’t match we need to find where they DID match:

Check if the value at the prior row is greater than the value at the prior col.

If it is, decrement row but leave col the same.

If it isn’t, decrement col but leave row the same.

You might need to reverse your result. It depends on how you construct the solution. Our solution is in the hint!

Code Review
Get targeted feedback about your code and how well it meets the objective of the project.
You can request 1 AI-powered review per project when you complete all tasks.
Code Editor
Output-only Terminal
10/10 complete
Back
Next
