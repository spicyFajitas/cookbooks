# Markdown Syntax

## Welcome to MkDocs

For full documentation visit [mkdocs.org](https://www.mkdocs.org).

## Commands

* `mkdocs new [dir-name]` - Create a new project.
* `mkdocs serve` - Start the live-reloading docs server.
* `mkdocs build` - Build the documentation site.
* `mkdocs -h` - Print help message and exit.

# Title Header

```markdown
# Title Header
```

As always, you can reference the [official documentation](https://squidfunk.github.io/mkdocs-material/) for more assistance.

## Secondary Header '##'

```markdown
## Secondary Header
```

### Third Header '###'

    ```markdown
    ### Third Header
    ```

### Code Block

```` markdown title="Title"
``` shell
# this is some code
sudo apt get update
```
````

### URL

[Displayed Text](https://someURL.com/)

```markdown
[Displayed Text](https://someURL.com/)
```

### Table

| Header 1 | Header 2 | Header 3 |
| -------- | -------- | -------- |
| column 1 | col. 2 | very wide column for demonstration purposes 3 |

```markdown
| Header 1 | Header 2 | Header 3 |
| -------- | -------- | -------- | 
| column 1 | col. 2 | very wide column for demonstration purposes 3 |
```

#####################################################################################################################
#####################################################################################################################
#####################################################################################################################

#####################################################################################################################
#####################################################################################################################
#####################################################################################################################

# IT Docs Coding and Text Examples for Documentation

## Purpose

This page is for anyone new to documentation and the coding that goes with it or for anyone who needs a reference while coding.

## Code vs Example

Code will be represented below ```like this sample text``` . This is due to the fact that examples written without the code format will show the result of the coding. Examples will generally be right after the coded line.

To code your own lines, use three ``` before and after the text you want to highlight. This is best used for code or to highlight a specific function that you want a user to focus on.

## Headers

Headers are for any new section within the document.

- Code: ```# This is header code```

The more ```#``` symbols you use the smaller the text becomes. Also the linter gets really angry with showing the results of these headers, so you will need to test them out as you make your edits and determine what size makes the most sense.

- Examples:

- ```# One Header Symbol - Also the largest header```

- ```## Two Header Symbols```

- ```### Three Header Symbols```

- ```#### Four Header Symbols```

- ```##### Five Header Symbols - Also the samllest header```

In general, you want to use one ```#``` for the maint header of the IT Doc. Two ```##``` for sub headers, and so on. Use the style as you would see fit and what makes the most sense.

What you do not see is in between the two sample texts is ```<br></br>```.

## Lists and Bulletpoints

Lists are great for anything you want done in a very specific order. Bulletpoints are used for anything you want to highlight as a step or function that does not need to be done in a specific order.

### Lists

Example: ```1.```

Each of these must be followed by no more or less than two spaces. Note that the deeper indented the list, it changes how the list is represented.

Example: ```1. Start```

1. Start with no spaces
  1. Second with two spaces
    1. Third with four spaces

### Bulletpoints

Example: ```*``` or ```-```

Each of these must be followed by no more or less than two spaces.

Example: ```- Bullet```

- Bullet 1
  - Bullet 2
    - Bullet 3

### Combination

1. List 1
  * Bullet 1
    1. List 2
      * Bullet 2

## Blockquotes

To create a blockquote, add a > in front of a paragraph.

Example:

```
> Dorothy followed her through many of the beautiful rooms in her castle.
```

Result:

> Dorothy followed her through many of the beautiful rooms in her castle.

## Nested Blockquotes

Blockquotes can be nested. Add a >> in front of the paragraph you want to nest.

Example:

```
> Dorothy followed her through many of the beautiful rooms in her castle.
>
>> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.
```

Result:

> Dorothy followed her through many of the beautiful rooms in her castle.
>
>> The Witch bade her clean the pots and kettles and sweep the floor and keep the fire fed with wood.

## Bolding, Italicize and Bold Italicize

One ```*``` on each side will italicize text. Two ```**``` on each side will bold text. Three ```***``` will bold and italicize text.

Example: ```***```

Similar to the code examnple in the beginning of the document, you have to start and end the word or sentance you want bolded with three *.

Example: ```*This will be a italicized statement.*```

Result: *This will be a bolded statement*

Example: ```**This will be a bolded statement.**```

Result: **This will be a bolded statement**

Example: ```***This will be a bolded statement.***```

Result: ***This will be a bolded and italicized statement***

## Adding a Hyperlink to Text

This is a very handy thing to do since you can embedded a hyperlink within text with some simple code. This will make your documentation look more clean while still highlighting where the reader should click to get to a certain site.

Example: ```[Google](https://google.com)```

Result: [Google](https://google.com)

## Fancy Table of Contents

If you have a lot of data and want to organize it within your documentation, you can create a fancy table

Example:

```
| Syntax      | Description |
| ----------- | ----------- |
| Header      | Title       |
| Paragraph   | Text        |
```

Result:

| Syntax      | Description |
| ----------- | ----------- |
| Header      | Title       |
| Paragraph   | Text        |

## Multiple Choice Selections

If you'd like to organize information so that only some is visible at a time, you can split it between mulitple choice selections. These can be nested as well.

```
=== "Choice 1"
    Information for choice 1
    === "Choice 1a"
        1. List item 1 for choice 1a
        1. List item 2 for choice 1a
    === "Choice 1b"
        Information for choice 1b
=== "Choice 2"
    Information for choice 2
```

=== "Choice 1"
    Information for choice 1
    === "Choice 1a"
        1. List item 1 for choice 1a
        1. List item 2 for choice 1a
    === "Choice 1b"
        Information for choice 1b
=== "Choice 2"
    Information for choice 2

## Notes and Secrets

If you have a bit of information that you want to display as an aside, you can choose to format it as either a note or a secret. The Note/Secret title can be replaced with a one-word title.

```
!!! Note
    Note contents

??? Secret
    Secret message!
```

!!! Note
    Note contents

??? Secret
    Secret message!

## Inserting a Photo

This can be handy if you have a screenshot or very specific example and want to add it to your documentation.

First you want to copy the image you want to have hosted into /it-docs/src/files/

Example:

```![](../file/demodoge.png)```

Result:

![](../file/demodoge.png)

## Referencing Another Page

You can link/reference another page in the docs by relative file path.

Example:

```[My proxmox documentation page](../homelab/proxmox.md)```

[My proxmox documentation page](../homelab/proxmox.md)

You can also link/refernece a specific header on the page.

Example:

```[my cloud init ubuntu template - proxmox documentation](../homelab/proxmox.md#cloud-init-ubuntu-template)```

[my cloud init ubuntu template - proxmox documentation](../homelab/proxmox.md#cloud-init-ubuntu-template)

## Check Lists

Not sure when you would want to use this, but this is a neat feature that Markdown can do.

Example:

```

- [x] @mentions, #refs, [links](), **formatting** supported

- [x] list syntax required (any unordered or ordered list supported)

- [x] this is a complete item

- [ ] this is an incomplete item

```

Result:

- [x] @mentions, #refs, [links](), **formatting** supported
- [x] list syntax required (any unordered or ordered list supported)
- [x] this is a complete item
- [ ] this is an incomplete item

## Website References

https://guides.github.com/features/mastering-markdown/

https://wordpress.com/support/markdown-quick-reference/

https://www.markdownguide.org/basic-syntax/
