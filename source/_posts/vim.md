---
title: vim
date: 2020-01-05 21:38:32
categories: utils
tags: vim
---

summary vim skills from vim official tutor

<!-- more -->

# Lesson 1, 2

- to insert or append text type:

  i	type inserted text: insert before the cursor

  A	type appended text: append after the line

- to delete the character at the cursor type: `x`

- type `dw` to delete a word

- type `d$` to delete to the end of the line
- many commands that change are made from an operator and a motion, a short list of motions:
  - w - until the start of the next word, EXCLUDING its first character.
  - e - to the end of the current word, INCLUDING the last character.
  - $ - to the end of the line, INCLUDING the last character.

---

Lesson 2 SUMMARY

1. To delete from the cursor up to the next word type: `dw`

2. To delete from the cursor to the end of a line type: `d$`

3. To delete a whole line type: `dd`

4. To repeat a motion prepend it with a number: `2w`

5. The format for a change command is:

   ```markdown
   	operator [number] motion
   where:
   	operation - is what to do, such as d for delete
   	[number] - is an optional count to repeat the motion
   	motion - moves over the text to operate on such as w(word), $(to the end of line), etc.
   
   ```

6. To move to the start of the line use a zero: 0

7. To undo previous actions, type: u (lowercase u)

   To undo all the changes on a line, type: U(capital U)

   To undo the undo's, type: CTRL-R(lowercase is ok)

---

Lesson 3 SUMMARY