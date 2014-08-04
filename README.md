# Wiki #

Wiki (working title) is intended to be a really simple wiki for personal use.

Features:
* Saves pages (written in markdown syntax) in a local git repository
* Displays those pages (rendered to HTML) back to the user when accessed
* Supports creating, editing, moving, and deleting pages
* Support for hierarchical categories (implemented as folders within the repository)
* Support for showing the edit history of a given page

## Installation ##

Wiki's only dependencies are git, a version of ruby >= 1.9, and the gems listed in the `Gemfile`. Wiki has been
tested on Ubuntu 12.04+ and OS X 10.9+. Other platforms may work, but are unsupported at this time.

To install and use, simply clone this repository, install the gems, edit the settings file, and run the application:

```
git clone https://github.com/fuzyll/wiki.git
cd wiki
bundle install --standalone
vim settings.json  # change the base_url and other options if necessary
bundle exec shotgun config.ru
```

This will start Wiki running on http://localhost:9393 on your local machine.

Wiki may also be used with a traditional web server like Apache or Nginx through Passenger. This is, however,
outside the scope of this document at this time.

## Roadmap ##

Short-Term:
* Add a way to diff two revisions of a page from history
* Add a way to revert a page to a previous revision
* Add a few "special pages":
    * List of all created pages (all `*.md` files in the repository, sorted by folder/category)
    * List of recent changes (basically just a global `git log` for the whole repository)
    * Comprehensive syntax guide with examples (since I turn on some non-standard markdown options)
    * Possibly a list of "orphaned pages" (pages that no other page links to)
* Fix the auto-generated table of contents stuff in redcarpet (no idea why this isn't working)
* Fix all remaining FIXMEs in the controller

Long-Term:
* JavaScript enhancements (markdown editor, status flashes, pre-post field validation, etc.)
* Add a preview option when editing a page
* Add code block functionality with automatic syntax highlighting
* Add the ability to upload files (not sure if this should be outside of the repository or not)
* Possibly support sub-section editing (like Wikipedia's little [Edit] links next to each heading)
* Possibly support "tags" in addition to "categories" (many -> many relationship instead of one -> many)
* Possibly implement users/authentication (it is conceivable that a small team may want to use Wiki)
* Possibly support HTTPS (not sure what would need to be changed for this, if anything)
* Possibly support additional back-ends (Postgres, SQLite)
* Possibly support migrating to (or from) other platforms (Wikipedia, DokuWiki, etc.)

## Alternatives ##

Wiki isn't for everyone. These other projects may be better suited for your needs:

* [Gollum](https://github.com/gollum/gollum) - GitHub's solution. Supports alternate syntaxes and is more user-friendly.
* [Commonplace](https://github.com/fredoliveira/commonplace) - Similar, but not backed by git (also supports Windows).
* [Git-Wiki](https://github.com/sr/git-wiki) - The absolute simplest alternative (implemented in a single file).
