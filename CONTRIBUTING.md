# Contribute to Travel Crew

Thank you for contributing! Travel Crew is an open-source project, maintained and operated by Kai Technologies Corp. that welcomes contributions from everyone. 
Please read our [code of conduct]().

This document outlines the procedures and what to expect when contributing a bug report, a feature request, or new code via a pull request.
If you want to contribute documentation have a look at the [Wiki](https://github.com/kaitech-corp/travelcrew/wiki).
To contribute tutorials or help documents, get in touch with the _Documentation leader_, [Randy Nolden](Randy@kaitechcorp.com).

**Please read** and **follow these guidelines** before submitting a bug report, feature request or pull request.
It really helps us efficiently process your contribution!

**Table Of Contents**  
[Report a bug](#bug-reports)   
[Request a feature](#feature-requests)   
[Contribute code](#contributing-code)

## Report a bug

Found a bug? Tell us all about it!

- If you notice something odd happening, try to make it happen again (reproduce it).
- If you can reproduce it, try to figure out if it's caused by the video format that you use or by Travel Crew.
- If it's caused by Travel Crew, make sure it **still occurs in the current development version** (where we continually fix problems) by checking out with git to the current `dev` branch of Travel Crew.
- If it looks like it's caused by Travel Crew (or if you're not sure) and still occurs on the current `dev` branch, submit a bug report to the [issue tracker](https://github.com/kaitech-corp/travelcrew/issues).
    - **Search the issue tracker** to make sure your problem has not been reported yet. If you find a relevant bug, comment there, even if it's an old or closed one!
    - Only if you don't find a relevant issue, open a new issue. A new issue does not generate more exposure/visibility than commenting on an existing one.
    - Make sure you give it a good title! A good title explains the core of the problem in about 5-10 words. (It's sometimes easier to write the title after you've written the description.)
    - In the description, include the following details:
        1. **relevant system information** such as which Travel Crew version, operating system and IDE you are using,
        2. what you were doing when you noticed the bug,
        3. what you expected to happen,
        4. what actually happened, and how to make it happen again (ie how to reproduce the bug).
    - If you can demonstrate the bug in a few lines of code, include this code in the description.
      But please __don't__ copy and paste your entire source file.
- Someone will be along to review your bug report and assign tags to it.
  You might be asked some questions about it, or you might not.
  If you don't hear back for a while don't despair, it's not being ignored!
  We're simply a busy bunch, but you will hear back eventually.


## Request a feature

We already have a formal [roadmap](https://github.com/kaitech-corp/travelcrew/wiki/RoadMap) for the project but nevertheless we are a community of people who each contributes to sections that we feel are important for the project.
Feature requests are therefore mostly a way of us discussing/feeling out together where we'd like the project to go.
This can sometimes involve a lot of discussion, as everyone uses Travel Crew differently.

Feature requests are created as Github Issues, just like bugs.
Feature requests are also where code that you or anyone else would like to include in a future pull request is **discussed before being implemented!**
If you're writing code to add a new feature that you think would be awesome to have in the core, that's great!
But please make sure it's been discussed as a feature request _before_ you submit your pull request, as that increases the chances that your pull request will be accepted.

Before opening a feature request, please search the issue tracker and confirm an existing request touching the same topic doesn't already exist.

- We are a friendly and open team, but communication over the internet can be difficult, so please be patient and understanding as we work through your requests.
  Usually a lot of discussion just means that we haven't thought about what you're requesting before, which is a good thing!
- Please don't expect that a general agreement in the discussion that a feature request is a good idea means it will get made immediately.
  As with most open source projects, the fastest way to get a feature made is to make it yourself, or if you are not a programmer, make friends with someone who is, introduce them to Travel Crew, and ask them to make it for you.

## Contribute code

We are more likely to accept your code if we feel like it has been discussed already.
If you are submitting a new feature, it's best if the feature has been discussed beforehand using [feature request](#feature-requests) or submitting feedback within the Travel Crew App.

- Try and match the style and practices you find in the code you are working with.
- Please write _descriptive commit messages_ for each of the commits that you make.
  They don't have to be in-depth, just a brief summary of what the commit contains. 

#### Organising your code


- Submit from a dedicated branch on your own repository **branched off from current `develop`**. Your branch should be only about a single topic or area of Travel Crew.
  If you have multiple things to submit, make separate branches for each topic and submit multiple pull requests.
  (This makes it easier to review different parts of your code separately, and get it into the core faster.)
- The branch name should start with either __feature-__ for features or __bugfix-__ for bug fixes.
    - For example, if your patch adds code to share content, your branch should be called something like __feature-share-content__.
    - Remember, _commit early, commit often_ - use commits to isolate small subsets of code.
      This granularity makes the code easier to deal with in cases where some things have to be modified/isolated/removed from the pull request.
- When you commit your files and you find you can't do that without using `git add -f/--force`, this is because of the existing gitignore patterns. _Think about if those files really should be in the repo in the first place_. 
  Then, instead of force-adding files which really should be in the repo (i.e. incorrectly match a gitignore pattern), correct the gitignore pattern (ask for help if necessary) and commit normally.
- Don't mix code style/formatting changes with bugfixes or features. They should be separate commits or better still, separate branches and separate pull requests.
- If you are able to do so, test your code on different platforms before submitting it, but at least test it on your platform to make sure it doesn't break anything.

#### Submitting the pull request

- Submit your pull request to the __`dev`__ branch of Travel Crew (which you branched off from), _not_ the `master` branch.
- All pull requests that contain changes that need to be in the changelog **must include respective `CHANGELOG.md`**.
- In the comments field on your new pull request, enter a description of everything that the code in the pull request does.
    - This description is the first contact most of the core team will have with your code, so you should use it to explain why your pull request is awesome and we should accept it.
    - Mention if the code has been tested and on what platform.